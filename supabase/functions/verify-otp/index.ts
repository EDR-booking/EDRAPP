import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface VerifyOTPRequest {
  email: string;
  otp: string;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  
  try {
    const { email, otp } = await req.json() as VerifyOTPRequest;
    
    if (!email || !otp) {
      return new Response(
        JSON.stringify({ error: "Email and OTP are required" }),
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
    
    // Check if the OTP is valid, not expired, and not used
    const { data, error } = await supabaseAdmin
      .from("otps")
      .select("*")
      .eq("email", email)
      .eq("otp_code", otp)
      .eq("used", false) // Only accept unused OTPs
      .gte("expires_at", new Date().toISOString())
      .order("created_at", { ascending: false }) // Get the most recent one
      .limit(1)
      .single();
    
    if (error || !data) {
      console.error("Invalid or expired OTP:", error);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: "Invalid or expired OTP" 
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
    
    // Mark the OTP as used
    const { error: updateError } = await supabaseAdmin
      .from("otps")
      .update({ used: true })
      .eq("id", data.id);
    
    if (updateError) {
      console.error("Error updating OTP status:", updateError);
      // Continue anyway since the OTP is still valid
    }
    
    // Optionally, create or update a user session here
    // For example, you could generate a JWT token for the user
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: "OTP verified successfully",
        // Include any user data or tokens here
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
    
  } catch (error) {
    console.error("Error in verify-otp function:", error);
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: "Internal server error" 
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
