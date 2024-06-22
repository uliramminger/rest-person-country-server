# main.rb
#===============================================================================

require 'sinatra'
require 'sinatra/namespace'

require 'csv'

#===============================================================================

Person = Struct.new( :id, :firstname, :lastname, :yearOfBirth )
DefaultPerson = { id: 0, firstname: "", lastname: "", yearOfBirth: 0 }

Country = Struct.new( :id, :name, :capital, :area )
DefaultCountry = { id: 0, name: "", capital: "", area: 0 }

#===============================================================================

namespace ENV.fetch( 'URL_ROOT', '' ) do

  get '' do
    "Hello world!"
  end

  get '/' do
    "Hello world!"
  end

  get '/api/v1/check' do
    "OK"
  end

  #------------------------------

  options '/api/v1/person' do
    content_type :json

    response.set_header( 'Access-Control-Allow-Origin', '*' )
    response.set_header( 'Access-Control-Allow-Methods', 'POST' )
    response.set_header( 'Access-Control-Allow-Headers', 'Content-Type,X-CSRF-Token' )

    {}.to_json
  end

  options '/api/v1/person/:id' do |id|
    content_type :json

    response.set_header( 'Access-Control-Allow-Origin', '*' )
    response.set_header( 'Access-Control-Allow-Methods', 'PATCH,DELETE' )
    response.set_header( 'Access-Control-Allow-Headers', 'Content-Type,X-CSRF-Token' )

    {}.to_json
  end

  get '/api/v1/person' do    
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )

    values = []
    CSV.foreach( "person.csv" ) do |row|
      v = Person.new( *row ).to_h
      v[ :id ]          = v[ :id ].to_i
      v[ :yearOfBirth ] = v[ :yearOfBirth ].to_i
      
      values << v
    end

    values.to_json
  end

  get '/api/v1/person/:id' do |id|
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )

    values = []
    CSV.foreach( "person.csv" ) do |row|
      v = Person.new( *row ).to_h
      v[ :id ]          = v[ :id ].to_i
      v[ :yearOfBirth ] = v[ :yearOfBirth ].to_i

      values << v
    end

    value = (values.find { |v| v[:id] == id.to_i })

    if value
      value.to_json
    else
      status 404
    end
  end

  post '/api/v1/person' do
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )

    begin
      request_hash = JSON.parse( request.body.read, symbolize_names: true )

      # use DefaultPerson to define the order of the attributes, necessary for csv format
      data = DefaultPerson.merge( request_hash )
  
      values = []
      CSV.foreach( "person.csv" ) do |row|
        v = Person.new( *row ).to_h
        v[ :id ]          = v[ :id ].to_i
        v[ :yearOfBirth ] = v[ :yearOfBirth ].to_i
  
        values << v
      end
  
      maxid = values.max_by { |v| v[:id] } [:id]
      newid = maxid +1
  
      data[:id] = newid
  
      values << data
  
      CSV.open( "person.csv", "w" ) do |csv|
        values.each do |p|
          csv << p.values
        end
      end
      
      body ( { id: newid }.to_json )
      status 201
    rescue JSON::ParserError
      status 400
    end
  end

  patch '/api/v1/person/:id' do |id|
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )
    
    data = JSON.parse( request.body.read, symbolize_names: true )

    values = []
    CSV.foreach( "person.csv" ) do |row|
      v = Person.new( *row ).to_h
      v[ :id ]          = v[ :id ].to_i
      v[ :yearOfBirth ] = v[ :yearOfBirth ].to_i

      values << v
    end

    value = (values.find { |v| v[:id] == id.to_i })
    if value
      %i( firstname lastname yearOfBirth ).each do |attr|
        value[attr] = data[attr]
      end
    end

    CSV.open( "person.csv", "w" ) do |csv|
      values.each do |v|
        csv << v.values
      end
    end
    
    if value
      {}.to_json
    else
      status 404
    end
  end

  delete '/api/v1/person/:id' do |id|
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )
    
    values = []
    CSV.foreach( "person.csv" ) do |row|
      v = Person.new( *row ).to_h
      v[ :id ]          = v[ :id ].to_i
      v[ :yearOfBirth ] = v[ :yearOfBirth ].to_i

      values << v
    end

    value = (values.find { |p| p[:id] == id.to_i })
    values.delete( value )

    CSV.open( "person.csv", "w" ) do |csv|
      values.each do |v|
        csv << v.values
      end
    end
    
    if value
      {}.to_json
    else
      status 404
    end
  end

  #------------------------------

  options '/api/v1/country' do
    content_type :json

    response.set_header( 'Access-Control-Allow-Origin', '*' )
    response.set_header( 'Access-Control-Allow-Methods', 'POST' )
    response.set_header( 'Access-Control-Allow-Headers', 'Content-Type,X-CSRF-Token' )

    {}.to_json
  end

  options '/api/v1/country/:id' do |id|
    content_type :json

    response.set_header( 'Access-Control-Allow-Origin', '*' )
    response.set_header( 'Access-Control-Allow-Methods', 'PATCH,DELETE' )
    response.set_header( 'Access-Control-Allow-Headers', 'Content-Type,X-CSRF-Token' )

    {}.to_json
  end

  get '/api/v1/country' do
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )

    values = []
    CSV.foreach( "country.csv" ) do |row|
      v = Country.new( *row ).to_h
      v[ :id ]   = v[ :id ].to_i
      v[ :area ] = v[ :area ].to_i
      
      values << v
    end

    values.to_json
  end

  get '/api/v1/country/:id' do |id|
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )

    values = []
    CSV.foreach( "country.csv" ) do |row|
      v = Country.new( *row ).to_h
      v[ :id ]   = v[ :id ].to_i
      v[ :area ] = v[ :area ].to_i

      values << v
    end

    value = (values.find { |v| v[:id] == id.to_i })

    if value
      value.to_json
    else
      status 404
    end
  end

  post '/api/v1/country' do
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )

    begin
      request_hash = JSON.parse( request.body.read, symbolize_names: true )

      # use DefaultCountry to define the order of the attributes, necessary for csv format
      data = DefaultCountry.merge( request_hash )

      values = []
      CSV.foreach( "country.csv" ) do |row|
        v = Country.new( *row ).to_h
        v[ :id ]   = v[ :id ].to_i
        v[ :area ] = v[ :area ].to_i
 
        values << v
      end

      maxid = values.max_by { |v| v[:id] } [:id]
      newid = maxid +1

      data[:id] = newid

      values << data

      CSV.open( "country.csv", "w" ) do |csv|
        values.each do |p|
          csv << p.values
        end
      end
    
      body ( { id: newid }.to_json )
      status 201
    rescue JSON::ParserError
      status 400
    end
  end

  patch '/api/v1/country/:id' do |id|
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )
    
    data = JSON.parse( request.body.read, symbolize_names: true )

    values = []
    CSV.foreach( "country.csv" ) do |row|
      v = Country.new( *row ).to_h
      v[ :id ]   = v[ :id ].to_i
      v[ :area ] = v[ :area ].to_i

      values << v
    end

    value = (values.find { |v| v[:id] == id.to_i })
    if value
      %i( name capital area ).each do |attr|
        value[attr] = data[attr]
      end
    end

    CSV.open( "country.csv", "w" ) do |csv|
      values.each do |v|
        csv << v.values
      end
    end
    
    if value
      {}.to_json
    else
      status 404
    end
  end

  delete '/api/v1/country/:id' do |id|
    content_type :json
    response.set_header( 'Access-Control-Allow-Origin', '*' )
    
    values = []
    CSV.foreach( "country.csv" ) do |row|
      v = Country.new( *row ).to_h
      v[ :id ]   = v[ :id ].to_i
      v[ :area ] = v[ :area ].to_i

      values << v
    end

    value = (values.find { |p| p[:id] == id.to_i })
    values.delete( value )

    CSV.open( "country.csv", "w" ) do |csv|
      values.each do |v|
        csv << v.values
      end
    end
    
    if value
      {}.to_json
    else
      status 404
    end
  end

  #------------------------------

end

#===============================================================================
