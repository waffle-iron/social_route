module ApplicationHelper
  BASE_TITLE = 'The Social Route'

  def full_title(page_title)
    if page_title.empty?
      BASE_TITLE
    else
      "#{page_title} | #{BASE_TITLE}"
    end
  end

  def custom_bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      type = :success if type == :notice
      type = :error   if type == :alert
      text = "<script>toastr.#{type}('#{message}');</script>"
      flash_messages << text.html_safe if message
    end
    flash_messages.join("\n").html_safe
  end

  def account_status_codes(code)
    case code
    when 1
      "ACTIVE"
    when 2
      "DISABLED"
    when 3
      "UNSETTLED"
    when 7
      "PENDING_RISK_REVIEW"
    when 9
      "IN_GRACE_PERIOD"
    when 100
      "PENDING_CLOSURE"
    when 101
      "CLOSED"
    when 102
      "PENDING_SETTLEMENT"
    when 201
      "ANY_ACTIVE"
    when 202
      "ANY_CLOSED"
    end
  end
end
