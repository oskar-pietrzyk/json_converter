require 'csv'

class ConvertersController < ApplicationController
  def index
    @courses = Course.all
    render :index
  end

  def convert
    c = Course.create!(name: params[:name])
    c.update(converter_json: params[:converter_json])
  end

  def download
    course = Course.find_by(id: params[:id])
    json = JSON.parse(course.converter_json.file.read)
    headers = ["title", "format", "attachments", "links", "sources", "text/context"]

    csv_data = CSV.generate(headers: true) do |csv|
      csv << headers
      csv << ["TITLE: #{json['title']}", "Course type: #{json['course_type']}", "#{json['attachments'].count}", "", "", ""]
      binding.pry
      json['ordered_slides'].each do |slide|
        p_attr = slide['published_attributes']
        structured_body = p_attr['structured_body']
        csv << ["TITLE: #{p_attr['title']}", "#{p_attr['type']}", "", "", "",  "#{p_attr['serialized_body']}"
        ]

        if structured_body
          csv << ["--- DETAILS ---", "", "", "", "", "",]

          if structured_body['blocks'].present?
            csv << ["TEXT", "TYPE", "", "", "", "",]

            structured_body['blocks'].each do |block|
              csv << ["#{block['text']}", "#{block['type']}", "", "", "", ""]
            end
          end

          if structured_body['entityMap'].present?
            binding.pry
            csv << ["SOURCE TYPE", "SRC", "", "", "", "",]
          
            structured_body['entityMap'].each do |entityMap|
              csv << [ "#{entityMap.second['type']}", "#{entityMap.second['type'] === 'image' ? entityMap.second['data']['src'] : entityMap.second['data']['href'] }", "", "", "", ""]
            end
          end

          csv << ["--- END OF DETAILS ---", "", "", "", "", "",]
          csv << ["", "", "", "", "", "",]
        end
      end
    end

    send_data csv_data, :type => 'text/csv', filename: "data-#{Date.today.to_s}.csv", disposition: 'attachment'
  end
end

