import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { SMTPClient } from "https://deno.land/x/denomailer@1.6.0/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface TicketEmailRequest {
  email: string;
  ticketNumber: string;
  passengerName: string;
}

// SMTP Email sending function
async function sendTicketEmail(to: string, ticketNumber: string, passengerName: string): Promise<boolean> {
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

    const subject = `Your Ethiopian Railway Ticket #${ticketNumber}`;
    const htmlContent = `
      <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
            <h2 style="color: #1a5276;">🎫 Ethiopian Railway - Ticket Confirmation</h2>
            <p>Dear ${passengerName},</p>
            <p>Thank you for booking with Ethiopian Railway. Your ticket has been confirmed.</p>
            
            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
              <h3 style="margin: 0 0 10px 0; color: #1a5276;">Ticket Details</h3>
              <p style="margin: 5px 0;"><strong>Ticket Number:</strong> ${ticketNumber}</p>
              <p style="margin: 5px 0; color: #28a745; font-weight: bold;">Please keep this number safe for your reference.</p>
            </div>
            
            <p>You can use this ticket number to check your booking details or make changes to your reservation.</p>
            
            <p>Safe travels,<br>The Ethiopian Railway Team</p>
            
            <div style="margin-top: 30px; padding-top: 15px; border-top: 1px solid #e0e0e0; font-size: 12px; color: #6c757d;">
              <p>This is an automated message. Please do not reply to this email.</p>
            </div>
          </div>
        </body>
      </html>
    `;

    const textContent = `
      Ethiopian Railway - Ticket Confirmation
      -------------------------------------
      
      Dear ${passengerName},
      
      Thank you for booking with Ethiopian Railway. Your ticket has been confirmed.
      
      TICKET DETAILS:
      - Ticket Number: ${ticketNumber}
      
      Please keep this number safe for your reference.
      
      You can use this ticket number to check your booking details or make changes to your reservation.
      
      Safe travels,
      The Ethiopian Railway Team
      
      ---
      This is an automated message. Please do not reply to this email.
    `;

    await client.send({
      from: FROM_EMAIL,
      to: to,
      subject: subject,
      content: textContent,
      html: htmlContent,
    });

    await client.close();
    return true;
  } catch (error) {
    console.error("Error sending ticket email:", error);
    return false;
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { email, ticketNumber, passengerName } = (await req.json()) as TicketEmailRequest;
    
    if (!email || !ticketNumber) {
      return new Response(
        JSON.stringify({ error: "Email and ticket number are required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Send the email
    const emailSent = await sendTicketEmail(email, ticketNumber, passengerName || 'Valued Customer');
    
    if (!emailSent) {
      return new Response(
        JSON.stringify({ error: "Failed to send ticket email" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    return new Response(
      JSON.stringify({ success: true, message: "Ticket email sent successfully" }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error in send-ticket-email function:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
