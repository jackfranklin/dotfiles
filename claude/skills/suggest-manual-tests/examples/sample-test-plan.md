# Sample Manual Test Plan Example

Below is an example of a high-quality manual test plan that focuses on high-level steps rather than tedious UI actions:

### Manual Testing Scenarios

#### Scenario 1: User Registration with Valid Inputs

1. Navigate to the registration page (e.g. https://example.com/register).
2. Enter a unique username, valid email, and a strong password.
3. Submit the registration form.
4. Verify:
    - The client-side validation passes.
    - A POST request is sent to `/api/register` with correct JSON payload.
    - The response returns status `201 Created` with a user token.
    - The browser redirects to the dashboard page.
    - A welcome email notification is logged or sent.

#### Scenario 2: Requesting Registration with Existing Email

1. Navigate to the registration page.
2. Enter the same email address used in Scenario 1.
3. Submit the registration form.
4. Verify:
    - The API returns `409 Conflict` or a validation error indicating the email is already in use.
    - An error banner is displayed at the top of the form with clear instructions.
    - The password field is cleared but other fields retain their values.
