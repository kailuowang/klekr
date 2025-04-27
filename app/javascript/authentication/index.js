/**
 * Authentication Module
 * Handles login and user authentication features
 */

// Import authentication components
import Login from './login.js';

// Define authentication namespace
window.klekr = window.klekr || {};
window.klekr.Auth = window.klekr.Auth || {};

// Export components to authentication namespace
window.klekr.Auth.Login = Login;

export { Login };