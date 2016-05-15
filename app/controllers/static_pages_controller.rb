class StaticPagesController < ApplicationController

  def dashboard
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReportPdf.new('act_1219093434772270', params['cpm_by_placement'])
        send_data pdf.render, filename: "test.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end

  def overview
    @account = Account.find_by_account_id(params['account_id'])
  end

  def overview_adsets
    @campaign = Campaign.find_by_campaign_id(params['campaign_id'])
  end

  def reporting
    @account = Account.find_by_account_id(params['account_id'])
  end
end
