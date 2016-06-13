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
      text = "<script>toastr.success('#{message}');</script>"
      flash_messages << text.html_safe if message
    end
    flash_messages.join("\n").html_safe
  end

  def naming_errors
    campaign_naming_errors = Campaign.where(name_flagged: true).count
    adset_naming_errors = Adset.where(name_flagged: true).count
    ad_naming_errors = Ad.where(name_flagged: true).count

    if campaign_naming_errors > 0 || adset_naming_errors > 0 || ad_naming_errors > 0
      return campaign_naming_errors + adset_naming_errors + ad_naming_errors
    end
  end
end
