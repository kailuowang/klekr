# Setting Up Klekr Locally

## System Requirements
- Ruby 3.0.0 or later
- Rails 7.1.0
- SQLite3 (for development)

## Installation Steps

1. **Clone the repository**
   ```
   git clone <repo-url>
   cd klekr
   ```

2. **Install dependencies**
   ```
   gem install bundler
   bundle install
   ```
   
   Or use the provided setup script:
   ```
   bin/setup
   ```

3. **Database setup**
   ```
   bin/rails db:setup
   ```

4. **Flickr API Authentication**
   
   The application uses OAuth 1.0a for Flickr API authentication, following Flickr's official guidelines.
   
   Follow these steps to set up your Flickr authentication:
   
   a) Register for a Flickr API key at https://www.flickr.com/services/apps/create/
      - Choose "Apply for a non-commercial key"
      - Fill out the application information
      - Make sure to request "write" permissions
   
   b) Run the OAuth authentication script:
   ```
   bin/flickr_oauth
   ```
   
   c) Follow the prompts to:
      - Enter your API key and shared secret
      - The script will request a temporary token from Flickr
      - Open the authorization URL in your browser
      - Log in to Flickr and authorize the application
      - You'll receive a verification code from Flickr
      - Enter the verification code in the script
      - The script will exchange it for permanent OAuth tokens
      - The script will save the resulting OAuth tokens to your config file

5. **Start the server**
   ```
   bin/rails server
   ```

6. **Visit the application**
   
   Open your browser and go to `http://localhost:3000`

## Troubleshooting

If you encounter any issues with Flickr API authentication, make sure:

1. Your API key and shared secret are valid
2. You've obtained and added the OAuth tokens to your config file
3. The Flickr API service is available

For database issues, try:
```
bin/rails db:reset
```

Check the logs for more details on any errors:
```
tail -f log/development.log
```