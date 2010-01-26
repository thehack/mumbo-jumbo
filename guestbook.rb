require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'appengine-apis/users'

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
  property :profanity_num, Integer
  property :famous, Boolean
  property :letters_per_word, Integer
  property :words_per_sentence, Integer
  property :superlatives, Integer
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
"<center><a href='/admin/add_famous_people'>Famous Jumbos</a><br/><a href='/admin/cursewords'>cursewords (not implemented)</a><br/><a href='/admin/selfish'>Self-focused (not implemented)</a><br/><a href='/admin/@buzzwords'>@buzzwords (not implemented)</a><br/><a href='/admin/superlatives'>Superlatives (not implemented)</a>"
end

post '/newmumbo' do
	#defining some vars so we can use them in the model

@buzzwords = ["at the end of the day", "break through the clutter", "buzzword", "diversity", "ecotox", "empowerment", "exit strategy", "face time", "generation x", "globalization", "hit the ground running", "interflop", "leverage", "on the runway", "organic growth", "outside the box", "paradigm", "paradigm shift", "proactive", "sea change", "spin-up", "streamline", "synergy", "wellness", "win-win", "ballpark figure", "bandwidth", "baste the turkey", "business-to-business", "business-to-consumer", "best of breed", "best practices", "bizmeth", "boil the ocean", "brand", "brick-and-mortar", "business process outsourcing", "buzzword compliant", "client-centric", "circle back", "co-opetition", "core competency", "customer-centric", "downsizing", "drinking the kool-aid", "eat their own dog food", "event horizon", "eyeballs", "free value", "fulfilment issues", "going forward", "granular", "herding cats", "holistic", "infrastructure", "integrated", "knowledge process outsourcing", "logistics", "logistically", "long tail", "low hanging fruit", "make it pop", "metrics", "mindshare", "mission critical", "new economy", "next generation", "next level", "offline", "offshoring", "open kimono", "paperless office", "return on investment", "reverse fulfilment", "rich media", "rightshoring", "seamless integration", "share options", "shave the baby", "siloed", "solution", "state-of-the-art", "tail risk", "touch base", "value-added", "visibility", "aggregator", "ajax", "benchmarking", "back-end", "beta", "bleeding edge", "blog", "blogosphere", "bricks-and-clicks", "clickthrough", "cloud", "collaboration", "content management", "content management system", "convergence", "cross-platform", "design pattern", "digital divide", "digital remastering", "digital rights management", "digital signage", "document management", "dot-bomb", "download", "e-learning", "enterprise content management", "enterprise service bus", "framework", "folksonomy", "fuzzy logic", "immersion", "information superhighway", "innovation ", "mashup", "mobile", "modularity", "nanotechnology", "netiquette", "next generation", "podcasting", "portal", "real-time", "saas", "scalability", "social bookmarking", "social software", "spam", "struts", "sync-up", "tagging", "think outside the box", "user generated content", "virtualization", "vlogging", "vortal", "webinar", "weblog", "web services", "wikiality", "workflow", "vaporware", "information society", "political capital", "stakeholder", "truthiness", "elitist", "pork-barrel", "shore up", "rule of law"]

@profanity = ["ass " , "ass lick" , "asses " , "asshole" , "assholes" , "asskisser" , "asswipe" , "balls" , "bastard" , "beastial" , "beastiality" , "beastility" , "beaver" , "belly whacker" , "bestial" , "bestiality" , "bitch" , "bitcher" , "bitchers" , "bitches" , "bitchin" , "bitching" , "blow job" , "blowjob" , "blowjobs" , "bonehead" , "boner" , "brown eye" , "browneye" , "browntown" , "bucket cunt" , "bull shit" , "bullshit" , "bum" , "bung hole" , "butch" , "butt breath" , "butt fucker" , "butt hair" , "buttface" , "buttfuck" , "buttfucker" , "butthead" , "butthole" , "buttpicker" , "chink" , "christ" , "circle jerk" , "clam" , "clit" , "cobia" , "cock" , "cocks" , "cocksuck " , "cocksucked " , "cocksucker" , "cocksucking" , "cocksucks " , "cooter" , "crap" , "cum" , "cummer" , "cumming" , "cums" , "cumshot" , "cunilingus" , "cunillingus" , "cunnilingus" , "cunt" , "cuntlick " , "cuntlicker " , "cuntlicking " , "cunts" , "cyberfuc" , "cyberfuck " , "cyberfucked " , "cyberfucker" , "cyberfuckers" , "cyberfucking " , "damn " , "dick" , "dike" , "dildo" , "dildos" , "dink" , "dinks" , "dipshit" , "dong " , "douche bag" , "dumbass" , "dyke " , "ejaculate" , "ejaculated" , "ejaculates " , "ejaculating " , "ejaculatings" , "ejaculation" , "fag" , "fagget" , "fagging" , "faggit" , "faggot" , "faggs" , "fagot" , "fagots" , "fags" , "fart " , "farted " , "farting " , "fartings " , "farts" , "farty " , "fatass" , "fatso" , "felatio " , "fellatio" , "fingerfuck " , "fingerfucked " , "fingerfucker " , "fingerfuckers" , "fingerfucking " , "fingerfucks " , "fistfuck" , "fistfucked " , "fistfucker " , "fistfuckers " , "fistfucking " , "fistfuckings " , "fistfucks " , "fuck" , "fucked" , "fucker" , "fuckers" , "fuckin" , "fucking" , "fuckings" , "fuckme " , "fucks" , "fuk" , "fuks" , "furburger" , "gangbang" , "gangbanged " , "gangbangs " , "gaysex " , "gazongers" , "goddamn" , "gonads" , "gook" , "guinne" , "hard on" , "hardcoresex " , "hell " , "homo" , "hooker" , "horniest" , "horny" , "hotsex" , "hussy" , "jack off" , "jackass" , "jacking off" , "jackoff" , "jack-off " , "jap" , "jerk" , "jerk-off " , "jism" , "jiz " , "jizm " , "jizz" , "kike" , "knob" , "kock" , "kondum" , "kondums" , "kraut" , "kum " , "kummer" , "kumming" , "kums" , "kunilingus" , "lesbian" , "lesbo" , "loser" , "lust" , "lusting" , "merde" , "mick " , "mothafuck" , "mothafucka" , "mothafuckas" , "mothafuckaz" , "mothafucked " , "mothafucker" , "mothafuckers" , "mothafuckin" , "mothafucking " , "mothafuckings" , "mothafucks" , "motherfuck" , "motherfucked" , "motherfucker" , "motherfuckers" , "motherfuckin" , "motherfucking" , "motherfuckings" , "motherfucks" , "muff " , "nerd " , "nigger" , "niggers " , "orgasim " , "orgasims " , "orgasm" , "orgasms " , "pecker" , "penis" , "phonesex" , "phuk" , "phuked" , "phuking" , "phukked" , "phukking" , "phuks" , "phuq" , "piss" , "pissed" , "pisser" , "pissers" , "pisses " , "pissin " , "pissing" , "pissoff " , "porn" , "porno" , "pornography" , "pornos" , "prick" , "pricks " , "pussies" , "pussy" , "pussys " , "queer" , "retard" , "schlong" , "sheister" , "shit " , "shited" , "shitfull" , "shiting" , "shitings" , "shits" , "shitted" , "shitter" , "shitters " , "shitting" , "shittings" , "shitty" , "slag" , "sleaze" , "slut" , "sluts" , "smut" , "snatch" , "twat" , "wetback" , "whore" , "wop"]

	message = params[:message].downcase
  sentences = message.split(/[^a-zA-Z\,\;\"\'\-\_\(\)\*\%\^\$\$\@\~\+\=\{\}\[\]\:\<\>\s]/).length
  words = message.split(" ")
  wordnum = words.length
  letters = message.chomp.length
  
# calculate jargon
jargon= Array.new
@buzzwords.each do |b|
	jargon <<	message.scan(b)
end
jargon.flatten!

# calculate profanity
profanity= Array.new
@profanity.each do |p|
	profanity <<	message.scan(p)
end
profanity.flatten!

  selfish_words = %w[me myself i mine my]
  selfish = words - (words - %w[me myself i mine my personally])
  superlatives = (((words - ( words - %w[always amazing awesome best better crazy everybody hate honestly love most never nobody really super top-rated utmost utter very worst])).length))
	#clarity is determined by letters per word 
  clarity_metric = {3 => 12, 4 => 19, 5 => 25, 6 => 20, 7 =>15, 8 =>10}
  #brevity is determined by words per sentance.
  brevity_metric = {0 => 0, 1 => 1, 2 => 6, 3 => 11, 4 => 13, 5 => 15, 6 => 17, 7 => 20, 8 => 22, 9 => 25, 10 => 24, 11 => 23, 12 => 20, 13 => 19, 14 => 18, 15 => 16, 16 => 15, 17 => 12, 18 => 11, 19 => 10, 20 => 8, 21 =>7, 22 =>6, 23 =>5, 24 =>3}
	lpw = (letters/wordnum).round
	wps = (wordnum/sentences).round
	r_score = 25 - (100*(profanity.length + selfish.length + jargon.length)/wordnum)
	a_score = 25 - (superlatives*100/wordnum).round
	c_score = if lpw <= 2 || lpw >= 9
    		0
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
		:profanity_num => profanity.length,
    :accuracy_score => a_score,
    :superlatives => superlatives,
    :reach_score => r_score ,
    :clarity_score => c_score,
    :letters_per_word => lpw,
    :brevity_score => b_score,
    :words_per_sentence => wps,
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
	redirect '/'
end
