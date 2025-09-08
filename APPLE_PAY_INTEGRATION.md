# Apple Pay Integration for SkiniorX

This document outlines the complete Apple Pay subscription integration implemented for the SkiniorX Flutter app.

## Overview

The Apple Pay integration allows users to purchase subscription plans using Apple Pay, providing a seamless and secure payment experience. The implementation includes:

- Flutter/Dart service layer for payment processing
- iOS native code for Apple Pay authorization
- Subscription management with GetX state management
- Backend verification and subscription tracking

## Architecture

### 1. Flutter Layer

#### Models

- **`SubscriptionPlan`** (`lib/app/models/subscription_plan.dart`)
  - Represents subscription plan data
  - Includes pricing, features, and metadata
  - JSON serialization support

#### Services

- **`ApplePayService`** (`lib/app/services/apple_pay_service.dart`)
  - Main service for Apple Pay operations
  - MethodChannel communication with iOS
  - Backend API integration for payment verification

#### Controllers

- **`SubscriptionController`** (`lib/app/controllers/subscription_controller.dart`)
  - GetX controller for subscription state management
  - Handles plan selection and purchase flow
  - Manages loading states and error handling

#### Views

- **`SubscriptionView`** (`lib/app/views/subscription_view.dart`)
  - User interface for subscription plan selection
  - Apple Pay button integration
  - Responsive design with plan cards

### 2. iOS Native Layer

#### AppDelegate Configuration

- **`ios/Runner/AppDelegate.swift`**
  - MethodChannel setup for Flutter communication
  - Apple Pay availability checking
  - Payment authorization handling

#### Key Components

- **ApplePayDelegate**: Handles PKPaymentAuthorizationViewController events
- **MethodChannel**: Bridge between Flutter and iOS native code
- **PassKit Framework**: Apple's payment processing framework

## Implementation Details

### Flutter Service Methods

```dart
// Check if Apple Pay is available
static Future<bool> canMakePayments()

// Process subscription payment
static Future<bool> processSubscriptionPayment({required SubscriptionPlan plan})

// Get available subscription plans
static Future<List<SubscriptionPlan>> getAvailablePlans()

// Verify payment with backend
static Future<bool> _verifyPaymentWithBackend(String transactionId, String planId)
```

### iOS MethodChannel Methods

```swift
// Check Apple Pay availability
case "canMakePayments"

// Present Apple Pay payment sheet
case "presentApplePay"
```

### Backend Integration

The service communicates with the SkiniorX API for:

- **Plan Retrieval**: `GET /subscriptions/plans`
- **Payment Verification**: `POST /subscriptions/apple-pay/verify`

## Setup Requirements

### 1. Apple Developer Console

1. **Enable Apple Pay Capability**

   - In your app's capabilities, enable Apple Pay
   - Create and configure merchant identifiers
   - Generate payment processing certificates

2. **Merchant Identifier**

   - Create: `merchant.com.skinior.skiniorx`
   - Configure with your payment processor
   - Add to iOS app capabilities

3. **App Store Connect**
   - Configure subscription products
   - Set up subscription groups
   - Define pricing tiers

### 2. iOS Configuration

1. **Update `ios/Runner/Runner.entitlements`**:

```xml
<key>com.apple.developer.in-app-payments</key>
<array>
    <string>merchant.com.skinior.skiniorx</string>
</array>
```

2. **Update `ios/Runner/Info.plist`**:

```xml
<key>com.apple.developer.in-app-payments</key>
<array>
    <string>merchant.com.skinior.skiniorx</string>
</array>
```

### 3. Backend API Endpoints

#### Get Subscription Plans

```http
GET /api/subscriptions/plans
Authorization: Bearer {token}
```

Response:

```json
[
  {
    "id": "monthly",
    "name": "Monthly Pro",
    "description": "Get premium features with monthly billing",
    "price": 9.99,
    "currency": "USD",
    "duration": "monthly",
    "features": ["Unlimited analysis", "Personalized routines"],
    "isPopular": false,
    "isRecommended": false
  }
]
```

#### Verify Apple Pay Transaction

```http
POST /api/subscriptions/apple-pay/verify
Authorization: Bearer {token}
Content-Type: application/json
```

Request:

```json
{
  "transactionId": "transaction_id_from_apple",
  "planId": "monthly",
  "userId": "user_id"
}
```

Response:

```json
{
  "success": true,
  "subscriptionId": "sub_123",
  "status": "active",
  "expiresAt": "2024-02-01T00:00:00Z"
}
```

## Usage

### 1. Navigate to Subscription Screen

```dart
// From anywhere in the app
Get.to(() => const SubscriptionView());
```

### 2. Using the Controller

```dart
// Get controller instance
final subscriptionController = Get.find<SubscriptionController>();

// Load plans
await subscriptionController.loadAvailablePlans();

// Select a plan
subscriptionController.selectPlan(plan);

// Purchase selected plan
await subscriptionController.purchaseSelectedPlan();
```

### 3. Check Subscription Status

```dart
// Check if user has active subscription
if (subscriptionController.isSubscribed.value) {
  // Show premium features
}
```

## Security Considerations

1. **Payment Token Handling**

   - Payment tokens are never stored locally
   - Immediate verification with backend required
   - Secure transmission over HTTPS

2. **Backend Verification**

   - All transactions verified server-side
   - Apple receipt validation implemented
   - Subscription status tracked in secure database

3. **User Authentication**
   - Apple Pay transactions tied to authenticated users
   - JWT tokens used for API authorization
   - Session management with secure storage

## Testing

### 1. Simulator Testing

- Use Xcode simulator with test payment cards
- Configure sandbox environment in Apple Developer Console
- Test various payment scenarios (success, failure, cancellation)

### 2. Device Testing

- Use TestFlight builds for physical device testing
- Configure sandbox Apple ID for testing
- Test with real payment methods in sandbox mode

### 3. Production Testing

- Gradual rollout with limited user base
- Monitor payment success rates
- Track subscription activation metrics

## Error Handling

The implementation includes comprehensive error handling for:

- **Network Errors**: Connection timeouts, API failures
- **Payment Errors**: Apple Pay unavailable, user cancellation
- **Validation Errors**: Invalid plans, authentication failures
- **Backend Errors**: Server errors, verification failures

## Future Enhancements

1. **Restore Purchases**: Implement StoreKit for subscription restoration
2. **Subscription Management**: In-app subscription modification
3. **Promotional Offers**: Support for promotional pricing
4. **Analytics**: Enhanced payment tracking and metrics
5. **Multi-Currency**: Support for international pricing

## Support

For implementation questions or issues:

- Review Apple Pay developer documentation
- Check SkiniorX API documentation
- Consult Flutter MethodChannel guides
- Reference GetX state management docs

## Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  get: ^4.6.6
  http: ^1.1.0
  get_storage: ^2.1.1

dev_dependencies:
  flutter_test: sdk: flutter
```

iOS native dependencies are handled through iOS frameworks:

- PassKit
- StoreKit
- Foundation
- UIKit
