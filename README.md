# The Social Route

[![Throughput Graph](https://graphs.waffle.io/michaelDpierce/social_route/throughput.svg)](https://waffle.io/michaelDpierce/social_route/metrics/throughput)

## Whitelist Accounts Ids
- Go to The Social Route FB App
- Settings
- Advanced
- Add account_id at bottom of page
- Make sure to delete out the unneeded account_ids from both page and within the settings

## Import Data with Script
-Add wanted account_ids to bottom of import.rb script
-Run `bundle exec rake db:import`

## Testing with Localhost
-App Domain: Localhost
-Canvas URL: http://localhost:3000/
-OAuth Redirect URL: http://localhost:3000/users/auth/facebook
