class EditorsChoiceController < ApplicationController

  def show
    redirect_to exhibit_slideshow_path(collector_id: Collectr::Editor.new.ensure_editor_collector.id, rating: 2, order_by: 'date' )
  end

end