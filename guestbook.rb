require 'rubygems'
require 'sinatra'
require 'dm-core'

DataMapper.setup(:default, "appengine://auto")

# Create your model class
class Shout
  include DataMapper::Resource
  property :id, Serial
  property :message, Text
  property :jumbo_name, String
  property :shouted_at, Integer
  property :sentences, Integer
  property :words, Integer
  property :words_per_sentence, Integer
  property :letters_per_word, Integer
  property :buzzwords, Integer
  property :selfish_words, Integer
  property :clarity_score, Integer
  property :brevity_score, Integer
  property :accuracy_score, Integer
  property :reach_score, Integer
end

class Contact
  include DataMapper::Resource
   property :id, Serial
  property :email, String
end
  
# Make sure our template can use <%=h
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  # Just list all the shouts
  @shouts = Shout.all(:order => [:shouted_at.desc])
  @famous_mumbos = ['barack obama', 'kaynye west', 'jfk', 'george bush', 'charles dickens', 'bono', '_why', 'steve jobs', 'brittney']
  erb :index
end

post '/contact' do
	shout = Contact.create(
		:email => params[:email].downcase )
  redirect '/'
end

post '/' do
	#defining some vars so we can use them in the model
	message = params[:message].downcase
  sentences = message.split(/[^a-zA-Z\,\;\"\'\-\_\(\)\*\%\^\$\$\@\~\+\=\{\}\[\]\:\<\>\s]/).length
  words = message.split(" ")
  wordnum = words.length
  letters = message.chomp.length
  buzzwords = %w[actionable  assessment benchmark change coach compensation actions resolution constraints competencies practices dashboard deliverables diagnosis downsize enterprise excellence gatekeeper geographically dispersed headhunter  income pressures individual contributor leadership learning experience hornet mastery matrix organization momentum    nesting outcomes partnership positive momentum practical application process product service environment recommendation reengineer requirements revenue rightsize sigma standards superior performance supply chain synergy system teamwork touchpoints]
  selfish_words = %w[me myself i mine my]
  selfish = words - (words - %w[me myself i mine my])
  superlatives = (((words - ( words - %w[super best better most very really amazing awesome worst hate love nobody everybody always never honestly])).length)*2)/wordnum
  clarity_metric = {3 => 15, 4 => 20, 5 => 25, 6 => 20, 7 =>15, 8 =>10}
  brevity_metric = {0 => 0, 1 => 0, 2 => 5, 3 => 10, 4 => 10, 5 => 15, 6 => 15, 7 => 20, 8 => 20, 9 => 25, 10 => 25, 11 => 25, 12 => 20, 13 => 20, 14 => 20, 15 => 15, 16 => 15, 17 => 10, 18 => 10, 19 => 10, 20 => 10, 21 =>5, 22 =>5, 23 =>5, 24 =>5}
	lpw = (letters/wordnum).round
	wps = (wordnum/sentences).round
	r_score = 25 - (((words - (words - (buzzwords + selfish_words))).length)*25)/wordnum
  shout = Shout.create(
		:jumbo_name => params[:jumbo_name].downcase,
  	:message => message, 
    :shouted_at => Time.now.strftime("%m/%d/%Y at %I:%M%p"), 
    :sentences => sentences,
    :words => wordnum,
    :words_per_sentence => wps,
    :letters_per_word => lpw,
    :buzzwords => words.length - (words - buzzwords).length,
    :selfish_words => selfish.length,
    :accuracy_score => 25 - superlatives*5/wordnum,
    :reach_score => r_score ,
    :clarity_score => 
    	if lpw <= 2 || lpw >= 9
    		5
    	else 
    	clarity_metric[lpw]
    	end,
    :brevity_score =>
    	if wps > 24
    		0
    	else
    		brevity_metric[wps]
    	end
    )

  redirect '/'

end

get '/*/show' do
	@famous_mumbos = ['barack obama', 'kaynye west', 'jfk', 'george bush', 'charles dickens', 'bono', '_why', 'steve jobs', 'brittney']
	@jumbo_shouts = Shout.all(:jumbo_name => params[:'splat'])
	@shout = Shout.first(:jumbo_name => params[:'splat'])
	@total_score = @shout.brevity_score + @shout.clarity_score + @shout.accuracy_score + @shout.reach_score
	erb :show
end

post '/shouts/*/delete' do
	@shout = Shout.get(params['splat'])
	@shout.destroy
	redirect '/'
end
