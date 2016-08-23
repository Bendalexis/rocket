class Admin::BillsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_is_admin
  layout "admin"

  def index
    @payment_amount = BillPayment.where(bill_status: ["success", "paid"]).sum(:amount)
    @payout_amount = BillPayout.where(bill_status: "success").sum(:amount)
    @bill_payments = BillPayment.bill_payment_by_project_id(["success", "paid"])
    # @bill_payout = BillPayment.where(bill_status: "success")
  end

  def payout_index
    @payment_amount = BillPayment.where(bill_status: ["success", "paid"]).sum(:amount)
    @payout_amount = BillPayout.where(bill_status: "success").sum(:amount)
    @bill_payouts = BillPayout.bill_payout_by_project_id(["success", "paid"])
  end

  def show_bill_payments
    query_type = params[:query_type]
    case query_type
    when "success_bill"
      @bill_payments = BillPayment.bill_payment_by_project_id(["success", "paid"])
    when "faild_bill"
      @bill_payments = BillPayment.bill_payment_by_project_id(["faild",""])
    when "wait_bill"
      @bill_payments = BillPayment.bill_payment_by_project_id(["wait", ""])
    else
      @bill_payments = BillPayment.bill_payment_by_project_id(["success", "paid"])
    end
    render json: @bill_payments
  end

  def show_bill_payouts
    query_type = params[:query_type]
    case query_type
    when "success_bill"
      @bill_payouts = BillPayout.bill_payout_by_project_id(["success", "paid"])
    when "faild_bill"
      @bill_payouts = BillPayout.bill_payout_by_project_id(["faild",""])
    when "wait_bill"
      @bill_payouts = BillPayout.bill_payout_by_project_id(["wait", ""])
    else
      @bill_payouts = BillPayout.bill_payout_by_project_id(["success", "paid"])
    end
    render json: @bill_payouts
  end

  def show_bill_payments_by_project
    @payments = BillPayment.success_payment_by_project(params[:id])
  end

  def payout
    @project = Project.find(params[:id])
    amount = BillPayment.where(bill_status: "success").group("project_id").sum(:amount)
    options = {project: @project, amount: amount[1] * 0.9}
    if FundingService.new(options).payout!
      BillPayment.where(project_id: params[:id]).update_all(bill_status: "paid")
      flash[:notice] = "资金发放成功！"
    else
      flash[:danger] = "资金发放失败！"
    end
    redirect_back(fallback_location: root_path)
  end


end