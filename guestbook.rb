require 'rubygems'
require 'sinatra'
require 'dm-core'

DataMapper.setup(:default, "appengine://auto")

# These are the classes
class Shout
  include DataMapper::Resource
  property :id, Serial
  property :jumbo_name, String
  property :clarity_score, Integer
  property :brevity_score, Integer
  property :accuracy_score, Integer
  property :reach_score, Integer
  property :total_score, Integer
  property :jargon, String
  property :jargon_num, Integer
  property :famous, Boolean
end

# Make sure our template can use <%=h
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  # Just list all the shouts
  @shouts = Shout.all(:order => [:id.desc], :limit => 8)
  @famous = Shout.all(:famous => true, :order => [:id.desc], :limit => 8)
 	@scores = Shout.all(:order => [:total_score.desc], :limit => 8)
  erb :index
end

get '/*/show' do
  @famous = Shout.all(:famous => true, :order => [:id.desc], :limit => 8)
  @shouts = Shout.all(:order => [:id.desc], :limit => 8)
	@shout = Shout.get(params[:'splat'])
	@scores = Shout.all(:order => [:total_score.desc], :limit => 8)
	erb :show
end

get '/admin/add_famous_people' do
	  @shouts = Shout.all(:order => [:jumbo_name.desc])
	erb :add_famous
end

get '/admin' do
"<center><a href='/admin/add_famous_people'>Famous Jumbos</a><br/><a href='/admin/cursewords'>cursewords (not implemented)</a><br/><a href='/admin/selfish'>Self-focused (not implemented)</a><br/><a href='/admin/buzzwords'>Buzzwords (not implemented)</a><br/><a href='/admin/superlatives'>Superlatives (not implemented)</a>"
end

post '/newmumbo' do
	#defining some vars so we can use them in the model
	message = params[:message].downcase
  sentences = message.split(/[^a-zA-Z\,\;\"\'\-\_\(\)\*\%\^\$\$\@\~\+\=\{\}\[\]\:\<\>\s]/).length
  words = message.split(" ")
  wordnum = words.length
  letters = message.chomp.length
  buzzwords = %w[actionable  assessment benchmark change coach compensation actions resolution constraints competencies practices dashboard deliverables diagnosis downsize enterprise excellence gatekeeper geographically dispersed headhunter  income pressures individual contributor leadership learning experience hornet mastery matrix organization momentum    nesting outcomes partnership positive momentum practical application process product service environment recommendation reengineer requirements revenue rightsize sigma standards superior performance supply chain synergy system teamwork touchpoints]
  
# calculate jargon

jargon= Array.new
buzzwords.each do |b|
	jargon <<	message.scan(b)
end
jargon.flatten!
  selfish_words = %w[me myself i mine my]
  selfish = words - (words - %w[me myself i mine my])
  superlatives = (((words - ( words - %w[super best better most very really amazing awesome worst hate love nobody everybody always never honestly])).length)*2)/wordnum
  clarity_metric = {3 => 15, 4 => 20, 5 => 25, 6 => 20, 7 =>15, 8 =>10}
  brevity_metric = {0 => 0, 1 => 0, 2 => 5, 3 => 10, 4 => 10, 5 => 15, 6 => 15, 7 => 20, 8 => 20, 9 => 25, 10 => 25, 11 => 25, 12 => 20, 13 => 20, 14 => 20, 15 => 15, 16 => 15, 17 => 10, 18 => 10, 19 => 10, 20 => 10, 21 =>5, 22 =>5, 23 =>5, 24 =>5}
	lpw = (letters/wordnum).round
	wps = (wordnum/sentences).round
	r_score = 25 - (((words - (words - (buzzwords + selfish_words))).length)*25)/wordnum
	a_score = 25 - superlatives*5/wordnum
	c_score = if lpw <= 2 || lpw >= 9
    		5
    	else 
    	clarity_metric[lpw]
    	end
  	b_score = if wps > 24
    		0
    	else
    		brevity_metric[wps]
    	end
  shout = Shout.create(
		:jumbo_name => params[:jumbo_name].downcase,
		:jargon => jargon.join(", "),
		:jargon_num => jargon.length,
    :accuracy_score => a_score,
    :reach_score => r_score ,
    :clarity_score => c_score,
    :brevity_score => b_score,
    :total_score => a_score + b_score + c_score + r_score
    )
redirect '/'+shout.id.to_s+'/show'
end

post '/shouts/*/delete' do
	@shout = Shout.get(params['splat'])
	@shout.destroy
	redirect '/'
end

post '/shouts/*/makefamous' do
	@shout = Shout.get(params['splat'])
	@shout.famous = true
	@shout.save
	redirect '/admin/add_famous_people'
end
