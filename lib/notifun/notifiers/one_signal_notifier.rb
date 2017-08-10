class Notifun::Notifier::OneSignalNotifier < Notifun::Notifier::ParentNotifier
  def notify!(text, title, uuid, options)
    if !defined?(OneSignal)
      @success = false
      @error_message = "OneSignal is not defined."
      return
    end
    api_key = options[:api_key].presence
    user_key = options[:user_key].presence
    app_id = options[:app_id].presence
    api_key ||= Notifun.configuration.push_config[:api_key]
    user_key ||= Notifun.configuration.push_config[:user_key]
    app_id ||= Notifun.configuration.push_config[:app_id]
    return false unless api_key.present? && user_key.present? && app_id.present?

    OneSignal::OneSignal.api_key = api_key
    OneSignal::OneSignal.user_auth_key = user_key

    params = {
        app_id: app_id,
        contents: {
            en: text
        },
        data:{
            notification:options[:push_data]
        },
        ios_badgeType: 'Increase',
        ios_badgeCount: 1,
        include_player_ids:[uuid]
    }
    begin
      response = OneSignal::Notification.create(params: params)
      @success = true
    rescue OneSignal::OneSignalError => e
      puts "--- OneSignalError  :"
      puts "-- message : #{e.message}"
      puts "-- status : #{e.http_status}"
      puts "-- body : #{e.http_body}"
      @error_message = response["error"].presence || "Failed to send push notification"
      @success = false
    end
  end
end
