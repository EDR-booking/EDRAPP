import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { SMTPClient } from "https://deno.land/x/denomailer@1.6.0/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface OTPRequest {
  email: string;
}

// SMTP Email sending function
async function sendEmail(to: string, otp: string): Promise<boolean> {
  try {
    const SMTP_HOST = Deno.env.get("SMTP_HOST") || "smtp.gmail.com";
    const SMTP_PORT = parseInt(Deno.env.get("SMTP_PORT") || "465");
    const SMTP_USERNAME = Deno.env.get("SMTP_USERNAME");
    const SMTP_PASSWORD = Deno.env.get("SMTP_PASSWORD");
    const FROM_EMAIL = Deno.env.get("FROM_EMAIL") || SMTP_USERNAME;
    
    if (!SMTP_USERNAME || !SMTP_PASSWORD) {
      console.error("SMTP credentials not set");
      return false;
    }
    
    const client = new SMTPClient({
      connection: {
        hostname: SMTP_HOST,
        port: SMTP_PORT,
        tls: true,
        auth: {
          username: SMTP_USERNAME,
          password: SMTP_PASSWORD,
        },
      },
    });

    await client.send({
      from: FROM_EMAIL,
      to: to,
      subject: "Your EDR Ticket Booking OTP",
      content: `Your OTP is: ${otp}`,
      html: `
        <html>
          <body>
            <h2>Your EDR Ticket Booking OTP</h2>
            <p>Your one-time password is: <strong>${otp}</strong></p>
            <p>This code will expire in 10 minutes.</p>
            <p>If you didn't request this, please ignore this email.</p>
          </body>
        </html>
      `,
    });

    await client.close();
    return true;
  } catch (error) {
    console.error("Error sending email:", error);
    return false;
  }
}

// Backup for testing - if email sending fails, this function logs the OTP
function logOTPForTesting(email: string, otp: string): void {
  console.log(`OTP for ${email}: ${otp}`);
  console.log("This would be sent via email in production:");
  console.log(`To: ${email}`);
  console.log(`Subject: Your EDR Ticket Booking OTP`);
  console.log(`Body: Your OTP is: ${otp}`);
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { email } = (await req.json()) as OTPRequest;
    
    if (!email) {
      return new Response(
        JSON.stringify({ error: "Email is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Create a Supabase client with the Admin key
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    // Generate a 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 10); // OTP expires in 10 minutes

    // Store the OTP in the database
    const { data, error } = await supabaseAdmin
      .from("otps")
      .insert([
        {
          email,
          otp_code: otp,
          expires_at: expiresAt.toISOString(),
          used: false,
        },
      ])
      .select();

    if (error) {
      console.error("Error storing OTP:", error);
      return new Response(
        JSON.stringify({ error: "Failed to generate OTP" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Try to send the email
    const emailSent = await sendEmail(email, otp);
    
    if (!emailSent) {
      // If email sending fails, log the OTP for testing
      logOTPForTesting(email, otp);
      console.warn("Email sending failed. Check your SMTP configuration.");
      // Continue anyway since we've stored the OTP
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: "OTP sent successfully",
        // For development/testing, you might want to include the OTP
        // In production, you should remove this
        ...(Deno.env.get("ENVIRONMENT") === "development" ? { otp } : {})
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error in send-otp function:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
