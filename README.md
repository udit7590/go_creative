Go Creative!
=============
This is a crowdfunding application where users can start their donation or investment projects. Interface is smooth and easy to use and also has an admin section to monitor the activity.

Initialization
=============

- Run rake db:create
- Run rake db:migrate
- Run rake db:seed
- create config/initializers/secret_token.rb file and store a secret key in **Gocreative::Application.config.secret_key_base**
- Create config/database.yml file(Refer config/database.yml.example) for reference. As we use postgres for our project currently, you need to provide your system login username as username for database settings.
- Create config/secrets.yml to further store your settings if required.

Configuration
=============
- Configure default email in config/initializers/devise.rb
  - config.mailer_sender = '<email>'
- Configure SMTP settings in config/environments/production.rb (And other environments as per your use case)
  - config.action_mailer.smtp_settings
