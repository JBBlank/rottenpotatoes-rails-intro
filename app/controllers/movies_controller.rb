class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    page_change = false
    
    if params[:ratings] != nil
      session[:ratings] = params[:ratings]
    elsif params[:ratings] == nil
      params[:ratings] = session[:ratings]
    end
    
    #If the params not nil, set the session to those params
    if params[:sort]
      @sort_choice = params[:sort]
      session[:sort] = params[:sort]
    #Session has previously been set, so make @sort_choice those values
    elsif session[:sort]
      @sort_choice = session[:sort]
      page_change = true
    #The titles and release date were not selected
    else
      @sort_choice = nil
    end
    
    #If the button for refreshing page is hit without any ratings assigned
    if params[:commit] == "Refresh" && params[:ratings].nil?
      @selected_ratings = nil
      session[:ratings] = nil
    #params has ratings to be sorted by
    elsif params[:ratings]
      @selected_ratings = params[:ratings]
    #params has no ratings so resort back to session ratings
    elsif session[:ratings]
      @selected_ratings = session[:ratings]
      page_change = true
    else
      @selected_ratings = nil
    end
    
    if page_change
      flash.keep
      redirect_to movies_path :sort => @sort_choice, :ratings => @selected_ratings
    end
    
    if @sort_choice == 'title' and @selected_ratings != nil
      @movies = Movie.where(:rating => @selected_ratings.keys).order(:title)
      @title_head = 'hilite'
    elsif @sort_choice == 'rating' and @selected_ratings != nil
      @movies = Movie.where(:rating => @selected_ratings.keys).order(:release_date)
      @release_head = 'hilite'
    end
    
    
  end



  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
