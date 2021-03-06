class HomepageController < ApplicationController
   
   def home
      @seed_type = Plant.Images.sample
      if session[:plant_id] == nil || Plant.find_by_id(@plant_id).nil?
        plant = Plant.create
        plant.save
        session[:plant_id] = plant.id
      end
      @plant_id = session[:plant_id]
      if !Plant.find_by_id(@plant_id).messages.empty?
        @curr_message = Plant.find_by_id(@plant_id).messages.last.text
      else
        @curr_message = "No message saved yet"
      end
      # when you come back to home view, you should pass into the params a plant_id
      # this will help render the proper image, text, or soundbyte back to the home view
      # if params[:plant_id]
        # @plant = Plant.find(params[:plant_id].to_i)
      # end
   end
   
  def check_nearby
    my_lat = params[:my_lat].to_f
    my_long = params[:my_long].to_f
    nearest_plant = Location.nearby_planting?(my_lat, my_long)
    distance = nearest_plant[0]
    location = nearest_plant[1]
    if distance < 50
      @location = location
      if location.plants.empty?
        @plant = Plant.all.first
      else
        @plant = location.plants.last
      end
      @location_id = @location.id
      @seed_type = Plant.Images.sample
      @lat = location.latitude
      @long = location.longitude
      if location.plants.empty?
        @png = 'x.png'
      else
        @png = location.plants.last.plant_pic
      end
    else
      @plant = Plant.all.first
      @lat = ""
      @long = ""
      @png = ""
    end
    respond_to do |format|
      format.js
    end
  end
  
  def save_seed
    plant = Plant.find_by_id(session[:plant_id])
    if Message.where(plant_id: plant.id).empty?
      m = plant.messages.build(:text => params[:comment])
    else
      m = plant.messages.last
      m.text = params[:comment]
    end
    m.save!
    render :json => {params: params, goto: map_path(:location_id => plant.location.id), success: plant.save}
    puts("YOU HAVE SUCCESSFULLY SAVED YOUR SEED :)")
  end 

  private
    # Use callbacks to share common setup or constraints between actions.

    # Never trust parameters from the scary internet, only allow the white list through.
    def choice_params
      params.permit(:my_lat, :my_long)
    end
  


end