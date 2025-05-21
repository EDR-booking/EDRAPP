# EDR App Payment Integration

This folder contains Supabase Edge Functions for integrating payment functionality with the EDR Ticket Booking app.

## Structure

- `initialize-payment/`: Edge function to initialize a payment
- `check-payment-status/`: Edge function to check the status of a payment

## Database Setup

Before deploying these functions, you need to create the payments table in your Supabase project:

```sql
CREATE TABLE payments (
  id SERIAL PRIMARY KEY,
  payment_id TEXT NOT NULL UNIQUE,
  amount NUMERIC NOT NULL,
  currency TEXT DEFAULT 'ETB',
  status TEXT DEFAULT 'pending', -- pending, processing, completed, failed
  customer_email TEXT NOT NULL,
  customer_name TEXT,
  ticket_id TEXT NOT NULL,
  ticket_number TEXT,
  description TEXT,
  reference TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  return_url TEXT
);

-- Create indexes for better performance
CREATE INDEX idx_payments_payment_id ON payments(payment_id);
CREATE INDEX idx_payments_ticket_id ON payments(ticket_id);
CREATE INDEX idx_payments_status ON payments(status);
```

## Deployment

1. Install Supabase CLI if you haven't already:
   ```
   npm install -g supabase
   ```

2. Log in to your Supabase account:
   ```
   supabase login
   ```

3. Link your project:
   ```
   supabase link --project-ref your-project-id
   ```

4. Deploy the functions:
   ```
   supabase functions deploy initialize-payment
   supabase functions deploy check-payment-status
   ```

## Chapa Integration

The current implementation includes placeholders for Chapa API integration. To fully implement Chapa:

1. Sign up for a Chapa account at [https://chapa.co](https://chapa.co)
2. Obtain your API keys from the Chapa dashboard
3. Update the `.env` file with your Chapa API keys
4. Uncomment and update the Chapa API code in both functions

## Testing

You can test these functions with Supabase CLI:

```
supabase functions serve --env-file .env
```

This will start the functions locally, allowing you to test them before deployment.

## Client Implementation

The Flutter app has already been updated to use these functions:

1. `PaymentService` handles communication with these Edge Functions
2. `PaymentController` manages the payment workflow
3. `PaymentScreen` provides the user interface for payment

## Additional Resources

- [Supabase Edge Functions documentation](https://supabase.com/docs/guides/functions)
- [Chapa API documentation](https://developer.chapa.co/docs)
