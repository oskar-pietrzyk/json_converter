require 'csv'

class ConvertersController < ApplicationController
  def index
    @courses = Course.all
    render :index
  end

  def convert
    c = Course.create!
    c.update(converter_json: params.dig(:course, :converter_json))
  end

  def download
    course = Course.find_by(id: params[:id])
    json = JSON.parse(course.converter_json.file.read)
    headers = ["title", "format", "attachments", "links", "sources", "text/context"]

      binding.pry
    csv_data = CSV.generate(headers: true) do |csv|
      csv << headers
      csv << ["#{json['title']}", "Course type: #{json['course_type']}", "#{json['attachments'].count}", "", "", ""]
      json['ordered_slides'].each do |slide|
        csv << [
          "#{slide['published_attributes']['title']}",
          "#{slide['published_attributes']['type']}", 
          "", 
          "", 
          "", 
          "#{slide['published_attributes']['serialized_body']}"
        ]
      end
    end
  
    send_data csv_data, :type => 'text/csv', filename: "data-#{Date.today.to_s}.csv", disposition: 'attachment'
  end
end

