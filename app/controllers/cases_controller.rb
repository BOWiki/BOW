# frozen_string_literal: true

# Cases controller
class CasesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show history followers]
  before_action :set_instance_vars, only: %i[edit new create]

  def new
    @this_case = current_user.cases.build
    @this_case.agencies.build
    @this_case.links.build
  end

  def index
    page_size = 12
    @total_cases = Case.count
    @recently_updated_cases = Case.sorted_by_update 10
    @cases = Case.order('date DESC').includes(:state).page(params[:page]).per(page_size)
  end

  # rubocop:disable Metrics/AbcSize
  def show
    eager_load_case = Case.includes(:comments, :subjects, :links)
    @this_case = eager_load_case.order('links.created_at DESC').friendly.find(params[:id])
    @comments = @this_case.comments
    @comment = Comment.new
    @subjects = @this_case.subjects
    @follow_id = current_user.follows.find_by_followable_id(@this_case.id) if user_signed_in?
    # Check to make sure all required elements are here
    unless @this_case.present?
      flash[:error] = 'There was an error showing this case. Please try again later'
      redirect_to root_path
    end
  end
  # rubocop:enable Metrics/AbcSize

  def create
    @this_case = current_user.cases.build(case_params)
    @this_case.blurb = ActionController::Base.helpers.strip_tags(@this_case.blurb)
    # TODO: Create a scope to send only to users who have chosen to receive email updates
    if @this_case.save
      flash[:success] = 'Case was created!'
      flash[:undo] = @this_case.versions
      redirect_to @this_case
    else
      set_instance_vars
      render 'new'
    end
  end

  def edit
    @this_case = Case.friendly.find(params[:id])
    @this_case.links.build
  end

  def followers
    @this_case = Case.friendly.find(params[:case_slug])
  end

  def update
    @this_case = Case.friendly.find(params[:id])
    @this_case.slug = nil
    @this_case.blurb = ActionController::Base.helpers.strip_tags(@this_case.blurb)
    if @this_case.update_attributes(case_params)
      flash[:success] = 'Case was updated!'
      CaseMailer.send_followers_email(users: @this_case.followers,
                                      this_case: @this_case).deliver_now
      redirect_to @this_case
    else
      set_instance_vars
      render 'edit'
    end
    
  rescue StandardError => e 
    Rollbar.exception(e)
  end

  def destroy
    begin
      @this_case = Case.friendly.find(params[:id])
      @this_case.destroy
      flash[:success] = 'Case was removed!'
      CaseMailer.send_deletion_email(users: @this_case.followers,
                                     this_case: @this_case).deliver_now
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = I18n.t('cases_controller.case_not_found_message')
    end
    redirect_to root_path
  end

  def history
    @this_case = Case.friendly.find(params[:case_slug])
    @case_history = @this_case.versions.order(created_at: :desc)
  rescue ActiveRecord::RecordNotFound
  end
  
  def undo
    @case_version = PaperTrail::Version.find(params[:case_slug])
    begin
      if @case_version.reify
        @case_version.reify.save
      else
        # For undoing the create action
        @case_version.item.destroy
      end
      flash[:success] = 'Undid that!'
    rescue StandardError
      flash[:alert] = 'Failed undoing the action...'
    ensure
      redirect_to root_path
    end
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  private

  def case_params
    params[:case][:date] ||= []
    params.require(:case).permit(
                                  :title,
                                  :age,
                                  :overview,
                                  :litigation,
                                  :community_action,
                                  :agency_id,
                                  :cause_of_death_name,
                                  :date,
                                  :state_id,
                                  :city,
                                  :address,
                                  :zipcode,
                                  :longitude,
                                  :latitude,
                                  :avatar,
                                  :remove_avatar,
                                  :video_url,
                                  :summary,
                                  :blurb,
                                  links_attributes: %i[id url title _destroy],
                                  comments_attributes: \
                                    I18n.t('cases_controller.comments_attributes').map(&:to_sym),
                                  subjects_attributes: \
                                    I18n.t('cases_controller.subjects_attributes').map(&:to_sym),
                                  agency_ids: []
                                )
  end

  # from the tutorial (https://gorails.com/episodes/comments-with-polymorphic-associations)
  # why did they set commentable here?
  def set_commentable
    @commentable = Case.friendly.find(params[:id])
  end

  def set_instance_vars
    @agencies = SortCollectionOrdinally.call(collection: Agency.all)
    @states = SortCollectionOrdinally.call(collection: State.all)
    @genders = SortCollectionOrdinally.call(collection: Gender.all, column_name: 'sex')
    @ethnicities = SortCollectionOrdinally.call(collection: Ethnicity.all, column_name: 'title')
  end
end
