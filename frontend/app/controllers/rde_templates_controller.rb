class RdeTemplatesController < ApplicationController

  set_access_control "manage_rde_templates" => [:create, :batch_delete]
  set_access_control "view_repository" => [:index, :show]

  def create
    template = JSONModel(:rde_template).from_hash(params['template'])

    id = template.save

    render :json => {id: id}

  end


  def index
    templates = JSONModel(:rde_template).all.map do |template|
      {
        :name => template.name,
        :id => template.id,
        :record_type => template.record_type
      }
    end

    render :json => templates

  end


  def show
    template = JSONModel(:rde_template).find(params[:id])

    render :json => template
  end


  def batch_delete

    params[:ids].each do |id|
      template = JSONModel(:rde_template).find(id)
      template.delete
    end

    redirect_to :action => 'index'
    
  end
end
