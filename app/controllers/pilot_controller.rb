class PilotController < ApplicationController
  layout "two_thirds"

  def manage
  end

  def cohort
    @cohort_list = CohortList.new
  end

  def create
    @cohort_list = CohortList.new(cohort_list_params)

    if @cohort_list.valid?
      @cohort_list.generate_cohort!

      redirect_to action: :success
    else
      render :cohort
    end
  end

  def success
  end

  private

  def cohort_list_params
    params.require(:cohort_list).permit(:csv)
  end
end
