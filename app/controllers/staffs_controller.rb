class StaffsController < ApplicationController
  filter_resource_access
  helper_method :sort_column, :sort_direction
  
  # GET /staffs
  # GET /staffs.xml
  def index
    #@staffs = Staff.find(:all, :conditions => ['name ILIKE ?', "%#{params[:search]}%"])
    @staffs = Staff.find(:all, :conditions => ['name ILIKE ?', "%#{params[:search]}%"],:order=>"name ASC")
    #@staffs = Staff.find(:all, :order => sort_column + " " + sort_direction, :conditions => ['name ILIKE ?', "%#{params[:search]}%"])
    @staff_filtered = Staff.with_permissions_to(:edit).find(:all, :order => sort_column + ' ' + sort_direction ,:conditions => ['icno LIKE ? or name ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%"])
    #@staffs = Staff.find(:all, :order => sort_column + ' ' + sort_direction ,:conditions => ['icno LIKE ? or name ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%"])

    respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @staffs }
        format.js
    end
  end
  
  def indexmessage
    @staffs = Staff.find(:all)
    
    respond_to do |format|
        format.js
    end
  end

  # GET /staffs/1
  # GET /staffs/1.xml
  def show
    @staff = Staff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff }
    end
  end

  # GET /staffs/new
  # GET /staffs/new.xml
  def new
    @staff = Staff.new
    @staff.qualifications.build
    @staff.kins.build
    @staff.loans.build
    @staff.vehicles.build
    

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff }
    end
  end

  # GET /staffs/1/edit
  def edit
    @staff = Staff.find(params[:id])
    @staff.vehicles.build if (@staff.vehicles && @staff.vehicles.count==0) || @staff.vehicles[0].nil?
    @staff.shift_histories.build if @staff.staff_shift_id!=nil
  end
  
  def borang_maklumat_staff
    @staff = Staff.find(params[:id])  
    #@staffs = Staff.search(params[:search])
    render :layout => 'report'
    #respond_to do |format|
        #format.html # index.html.erb  { render :action => "report.css" }
        #format.xml  { render :xml => @staffs }
    #end
  end
  
  #-----Test Ruport---------#
  
def ruport
      table = Staff.report_table(:all, :only => [:id, :name])
        #:only       => %w[icno name id],
        #:conditions => "staffs_id is not null",
        #:group      => "icno, name, id")

    #  grouping = Grouping(table, :by => "icno")

    #  name = Table(%w[platform name count])  

    #  grouping.each do |name,group|
     #   Grouping(group, :by => "name").each do |vname,group|
     #     name     << { "platform" => name, 
     #                   "name" => vname,
     #                   "count" => group.length }
      


    #  sorted_table = name.sort_rows_by("count", :order => :descending)
    #  g = Grouping(sorted_table, :by => "platform")

    #  send_data g.to_pdf,
    #    :type         => "application/pdf",
    #    :disposition  => "inline",
    #    :filename     => "report.pdf" 
    end
  
  
  #---------Test Ruport----#

  # POST /staffs
  # POST /staffs.xml
  def create
    @staff = Staff.new(params[:staff])

    respond_to do |format|
      if @staff.save
        flash[:notice] = t('staff.title')+" "+t('created')
        format.html { redirect_to staffs_path }
        format.xml  { render :xml => @staff, :status => :created, :location => @staff }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /staffs/1
  # PUT /staffs/1.xml
  def update
    #params[:staff][:existing_qualification_attributes] ||= {}
    #raise params.inspect
    @staff = Staff.find(params[:id])
    c_shift = params[:staff][:staff_shift_id]
    if @staff.shift_histories.count > 0
      ind=@staff.shift_histories.count-1
    else
      ind=0
    end
    if params[:staff][:shift_histories_attributes]
      s_shift = params[:staff][:shift_histories_attributes]["#{ind}"][:shift_id]
      new_ddate= params[:staff][:shift_histories_attributes]["#{ind}"][:deactivate_date]
      @staff.create_shift_history_nodate(s_shift, c_shift, new_ddate) if (c_shift!=s_shift) && @staff.shift_histories.count==0 #&& new_ddate==""
    end
    respond_to do |format|
      if @staff.update_attributes(params[:staff])
        flash[:notice] = t('staff.title')+" "+t('updated')
        format.html { redirect_to staff_path(@staff) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /staffs/1
  # DELETE /staffs/1.xml
  def destroy
    @staff = Staff.find(params[:id])
    @staff.destroy

    respond_to do |format|
      format.html { redirect_to(staffs_url) }
      format.xml  { head :ok }
    end
  end
  
  private

  def sort_column
      Staff.column_names.include?(params[:sort]) ? params[:sort] : "icno" 
  end
  def sort_direction
      %w[asc desc].include?(params[:direction])? params[:direction] : "asc" 
  end
  
  def for_staffgradeid
    @staffs = Staff.find( :all, :conditions => [" staffgrade_id = ?", params[:id]]  ).sort_by{ |k| k['name'] }    
    respond_to do |format|
      format.json  { render :json => @staffs }      
    end
  end
  
end
