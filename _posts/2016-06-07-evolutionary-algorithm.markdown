---
layout: post
title:  "Optimizing Image Preprocessing for OCR"
date:   2016-06-07
slug: "optimizing-ocr-params-via-genetic-algorithm"
description: "Using genetic algorithms to improve OCR accuracy, specifically targetting the preprocessing stage"
categories: ocr genetic-algorithm
---

# Introduction
I've been playing around with [Tesseract](https://github.com/tesseract-ocr/tesseract) to OCR documents for a few months, and one of the things I've learned is how important image preprocessing is. Files that are initially unreadable by Tesseract can yield fairly good results if you can optimize the images properly.

While there are some basic heuristics for improving OCR quality, (increasing image size, increasing contrast) the actual parameters vary from image to image. I tried adaptive transformations via [openCV](http://docs.opencv.org/2.4/modules/imgproc/doc/miscellaneous_transformations.html) but they didn't work as effectively as I would've liked. At this point, my goal was to somehow determine optimal preprocessing parameters on a per-image basis. 

I decided to try utilizing a [genetic algorithm](https://en.wikipedia.org/wiki/Genetic_algorithm) to make this work. I hoped a GA would be able to optimize images in an efficient manner - at least compared than a neural network or a brute force approach.

If you aren't familiar genetic algorithms, I recommend reading the wiki article linked above - I'm by no means an expert, but I believe I can provide the basic building blocks through this post.


# First Steps
First, I found an image that Tesseract had issues with. I went with this:

[smartphone.jpg](/assets/images/smartphone.jpg)

Default Tesseract 3.04 Output looks like this:

~~~
human, the [mums-ulna 1m , >
hummluuunovutluvliﬂu‘

mum may»: mm m u m. Gm! l-‘imll.

”mum“ and mm] mm pom-In vim-1| privnle
nmrh. or was; Ilw sawmmcnl has wmpliamd the liws ofchimo ‘
moms soaking the mm scienliﬁc dm ﬁvm ubm-xi mphie
«Manama; furdip m on Shunemack and nudmb albumin:
mlim-mlimtiom m Amerian uniwmn'u

‘lflmkﬂltopmmlndﬂlmwmnemon mm, m
m up {or um.“ Ms. Jinn. 25. 5.ch

ah- mind some on!» mm mm mm. Imam
mug-g; ‘ \ thc-uhorim-s had eﬂecﬁvdyloknmd the
mammalian cl\'.F.N,s 1» .1 tin-1...: for minim: aim (mm
ammlogim m {omiyx inva‘wn. who rely huvily on lulu
m the 1mm

um uﬁ‘nrhiswuh any. numberMVJN. comp-nus, indudm
9WVFNndﬁﬂdem‘mmphinnd aunt: mmxmmm
“WW“ “W m “MMWumh-m
mmﬁmmwmmmmmuhm
~~~

...Not great! If we increase the size by 300% and run it again, we'll get something like this:

`$ convert smartphone.jpg -resize 300% smartphonebig.jpg` (I'm using imagemagick)

[smartphonebig.jpg](/assets/images/smartphonebig.jpg)

~~~
“M11353"! Mlp;_.',4n)1yims lSzlENV

gm 3 . " f" .
BEIJING 3.;ng Yuechcn. the foundet ohn Interact m height the
Grins-em has no interest in osuthtvwin; till Wt 9&1“
“minim headhunting m. nation‘l mmwmﬂ
limits: «mm- to browse photo-WWWp-ﬁickrmd;

mummmammmb’wwm

mun‘ty analysts [du- to u the Great Fimwall.

Byhtufuin‘ with Mill and several other popular virtual private
networks. or V.P.N.s. the government has complicated the lives of Chinese
mount-ts seeking the latest scientiﬁc data from abroad, graphic
design! shopping {or dip an on Shutterstock and students submitting
online appliutions to American universitiu.

"lﬂtwu legal to protest md throw mnen eggson the stmet. I'd
deﬁnitely up for tint." Ms. Jinx. 25. said.

m laugh-d some ofthc world's most m Internet

° g. . h ‘ m. the Mborities had effectively tolerated the
pmlecration of \'.P..\'.s as a lifeline for mmiomof peoﬂz. from

anchaeologists to fonign invatom, who rely havilyon less-{ct v 2.? ‘ .'.' “ .

tothc Internet.
Buteaﬂiu'tltismaﬁu'l numbeI’OfVJ’Jl. companies, handing
sumngVPNIndGolden Frugmmplained thntheChinuexm'cmmunh-d
dimptdthdrmﬂthunpmbdmmamiﬂm
fortbeﬁMﬁneWitshmd in themuﬂimplidﬂy
~~~

Hey, that's a lot better! Now let's try using [Textcleaner](http://www.fmwconcepts.com/imagemagick/textcleaner/) with default parameters and try it again. Textcleaner is script that attempts to clean the background of a text based image via imagemagick. It has a lot of parameters you can tweak to clean the image properly based on what's wrong with it. I encourage briefly checking out the documentation I just linked to get a rough idea of what these parameters are. 

`$ ./textcleaner smartphonebig.jpg smartphonebigcleaned.jpg`

[smartphonebigcleaned.jpg](/assets/images/smartphonebigcleaned.jpg)

~~~
._-— w-..

- momfn

~ GbFI-Y‘w york Eimt‘ﬂ http:,.r‘/r1yti.n15!1535M

ASIA FACING

- --€hina~Further_ Tightensprip on ﬂielnternet

nyANDRE‘VJ A0055 Lt." 3,2015 “‘ ,\
BEIJING — .ling Yneehen. the founder ofnn internet stztrt-up‘here in the
Chinese capital. has no interest in overthrowing the Connnnnitt Party. But
these dap‘ she ﬁndx hemclfcuming thenation's smothering cyberpoiice us
she tries — and fails -— to browse photo-sharing websites like liliekr 11nd
alt-113.3112: to stay in touch m'th the anbool; friends she has made during:
trips to France. India and Singapore. -

Gntail hze; heeozne ulnmx't impoyihh! to use here. and in reeentts‘eeiet
the nulltoritlm have gummed up Astrill, the software his. Jing and countless
othemdepended on toeixui111\'c11Ltlu-J11ternet restrictiontithnt ween ~ ~ 7
security analyxts refer to as the Great rim—.111. V -

By interfering with Astriil and several other popular virt 11:11 primte
networks‘. or V.P.N.s. the government has complicated the tins of Chinese
astronomers seeking the latest scientiﬁc data from abroad, graphic
(imigncm shopping {or clip art on Shuttcrxtock and students submitting
online apipiimtiom: to Amerimn universities.

"If it Was lmal to protest and throw rotten egg; on the street, I'd
deﬁnitely be up {or that." Ms. Jing. 25. said.

China has long had some ofthe \mrld's most onerous Internet

mi‘imﬂf“ But until non. the authorities had effectii. eiy tolerated the
pmlifemtion of V P.N.s as a lifeline for millions of people. from ~. -_ 4
archaeologist to foreign 1m atom, v. ho rel) heatin on lew-fettered ace-3.:
to the Internet.

But cariierthic txeek. after a number ofV. RN. companies, includiny
StmngVPV and Golden Frog. complained that the Chinese gotcmmcm had
d‘SWP‘L‘d thdr Smiccs \sitii unprum-dented wphistication. a Senior official

{or-the tint time acknotslcdged its hand in the attack: and impugn).

n.-- ...._....—————
~~~

Okay that's great compared to the original, but it still could be better right?

# Genetic Algorithm

I'll walk through a basic genetic algorithm I wrote in ruby. The gist of it is this:

1. Create the initial population by randomly initializing a number of sets of textcleaner parameters
2. Process an image with each set of parameters, OCR the result with Tesseract
3. Use some sort of fitness function to evaluate the results
4. Select
5. Mate
6. Crossover
7. Mutate

## individual.rb
First we're going to model the `individual`. You can think of an individual as a set of textcleaner parameters. I chose the ones I thought were relevant from textcleaner's documentation.

We're going to have two fields: `fitness`, and `gene_string`. Fitness is how 'good' the individual's set of parameters are (I'll get to that soon). The gene string is an array of numbers corresponding to value of each textcleaner parameter.

The `options` method simply returns the `options` in a string format, needed for when we call textcleaner.

`calc_fitness` calculates its fitness via `FitnessCalc`. 

~~~ ruby
require_relative 'fitness_calc'

class Individual
  attr_accessor :fitness, :gene_string

  def initialize
    @fitness = 0
    @gene_string = []

    @gene_string << rand(0..2)   # enhance
    @gene_string << rand(0..50)  # filtersize
    @gene_string << rand(0..20)  # offset
    @gene_string << rand(0..1)   # unrotate
    @gene_string << rand(0..50)  # threshold
    @gene_string << rand(0..100) # sharpamt
    @gene_string << rand(0..200) # saturation
    @gene_string << rand(0..100) # adaptblur
    @gene_string << rand(0..1)   # trim

  end

  def options
    enhance = ["none", "stretch", "normalize"] # -e
    unrotate = [true, false] # -u
    trim = [true, false] # -T

    enhance = "-e " + enhance[@gene_string[0]]
    filtersize = "-f " + @gene_string[1].to_s
    offset = "-o " + @gene_string[2].to_s
    unrotate = @gene_string[3] == 1 ? "-u" : ""
    threshold = "-t " + @gene_string[4].to_s
    sharpamt = "-s " + (@gene_string[5] / 100.to_f).to_s
    saturation = "-S " + @gene_string[6].to_s
    adaptblur = "-a " + (@gene_string[7] / 100.to_f).to_s
    trim = @gene_string[8] == 1 ? "-T" : ""

    "-g #{enhance} #{filtersize} #{offset} #{unrotate} #{threshold} #{sharpamt} #{saturation} #{adaptblur} #{trim}"
  end

  def calc_fitness
    @fitness = FitnessCalc.new("smartphone-big.jpg").fitness_calc(self.options)
  end

end
~~~

## fitness_calc.rb

This is how we determine how 'fit' an individual is. In this example, I simply decided to go with counting how many english words were found in the OCR results by using a dictionary file. It's important to choose a fitness function that accurately assesses whether or not you're getting closer to your goal .

`fitness_calc` actually does the calculation. It runs textcleaner with the specified parameters, and then OCRs the temporary file. After that it counts the number of words that were found in the dictionary, and then deletes the temporary files.

~~~ ruby
class FitnessCalc

    def initialize(input_file)
        @dictionary = {}
        File.open("./en.txt") do |file|
            file.each do |line|
                @dictionary[line.strip] = true
            end
        end

        @input_file = input_file
        @output_file_name = File.basename(@input_file, File.extname(@input_file))
        @output_file_ext = File.extname(@input_file)
    end


    def fitness_calc(options)
        rand_int = "#{rand(15000)}"
        output_file = @output_file_name + rand_int + @output_file_ext
        tess_output_file = @output_file_name + rand_int

        system "mkdir #{@output_file_name}"
        system "./textcleaner #{options} #{@input_file} #{@output_file_name}/#{output_file}"
        system "tesseract #{@output_file_name}/#{output_file} #{@output_file_name}/#{tess_output_file}"

        count = 0
        words = File.read("#{@output_file_name}/#{tess_output_file}.txt").downcase.split
        words.each do |word|
            if @dictionary[word]
                count += 1
            end
        end

        begin
          File.delete("#{@output_file_name}/#{output_file}")
          File.delete("#{@output_file_name}/#{tess_output_file}.txt")
        rescue
          puts 'file doesnt exist'
        end

        count
    end
end
~~~

## population.rb

Straightforward, this is how we're generatoring and storing our sets of individuals. We can also find the fittest individual through the `fittest_individual` method.

~~~ ruby
require_relative 'individual'

class Population
  attr_accessor :individuals

  def initialize(population_size, generate = true)
    @individuals = []
    if generate
      population_size.times do |individual|
        @individuals << Individual.new
      end
    end
  end

  def fittest_individual
    @individuals.max_by(&:fitness)
  end
end
~~~

## genetic.rb

This ties everything together. First, we set some parameters for our genetic algorithm.

- POP_SIZE = population size for each generation. If you increase this, you'll get more individuals but it will really slow down each iteration.
- UNIFORM_RATE = this affects how many 'genes' get combined between two individuals.
- MUTATION_RATE = this affects how likely a gene is to mutate between generations.
- TOURNAMENT_SIZE = this is how many individuals should participate in the tournament selection process.
- ELITISM = this determines whether or not you keep the most fit individual between generations.

Then we initialize a new population, which will generate a number of individuals with randomized genes. This is Generation 0. From there, we create a loop that continually calls `evolve_population` and prints the results (each iteration being a new generation).

`evolve_population` has several steps. First, it creates a blank population. If ELITISM is true, it sets the most fit individual from the previous generation to the first spot in the new population. It also sets an offset to prevent later functions from interacting with the fittest individual.

Then it loops over the remaining empty population spots and fills them with `tournament_selection` and `crossover`. `tournament_selection` takes a random sample of the previous generation and selects the fittest individual from that subgroup. `crossover` takes two individuals (selected by `tournament_selection`) and randomly combines their genes to form a new individual.

Once we have a fresh population from the previous operations, we mutate them. `mutate` goes through each gene (textcleaner parameter) and potentially increases or decreases its value. I set some weights to help in this because the domains of each parameter vary.

Finally, we calculate the fitness of the new population and return it. This sets us up repeat the process for the next generation.

~~~ ruby
require_relative 'population'
require_relative 'individual'
require 'pp'

# edit these for profit
POP_SIZE = 10
UNIFORM_RATE = 0.5
MUTATION_RATE = 0.25
TOURNAMENT_SIZE = 5
ELITISM = true

def evolve_population(population)
  new_population = Population.new(POP_SIZE, false)
  elitism_offset = 0

  # keep the best individual
  if (ELITISM)
    new_population.individuals[0] = population.fittest_individual
    elitism_offset = 1
  end

  # loop over population size and crossover
  (elitism_offset..population.individuals.size - 1).each do |i|
    individual1 = tournament_selection(population)
    individual2 = tournament_selection(population)
    baby = crossover(individual1, individual2)
    new_population.individuals[i] = baby
  end

  # mutate population
  (elitism_offset..population.individuals.size - 1).each do |i|
    new_population.individuals[i].gene_string = mutate(new_population.individuals[i])
  end

  # calculate fitness
  threads = []
  (elitism_offset..population.individuals.size - 1).each do |i|
    threads << Thread.new {
      new_population.individuals[i].calc_fitness
    }
  end
  threads.each { |thr| thr.join }

  new_population
end

def crossover(individual1, individual2)
  baby = Individual.new

  baby.gene_string.each_with_index do |g, index|
    if rand <= UNIFORM_RATE
      baby.gene_string[index] = individual1.gene_string[index]
    else
      baby.gene_string[index] = individual2.gene_string[index]
    end
  end

  baby

end

def mutate(individual)
  weights = [0, 2, 2, 0, 3, 5, 10, 20, 10, 0]

  individual.gene_string.each_with_index.map do |g, i|
    if rand <= MUTATION_RATE
      if i == 0
        g = [0,1,2].sample
      elsif i == 3
        g = [0,1].sample
      elsif i == 8
        g = [0,1].sample
      else
        g += (rand(-1..1) * weights[i])
      end
    else
      g
    end
  end
end

def tournament_selection(population)
  tournament_population = Population.new(TOURNAMENT_SIZE, false)
  tournament_population.individuals = population.individuals.sample(TOURNAMENT_SIZE)
  fittest_individual = tournament_population.fittest_individual
end


population = Population.new(POP_SIZE, true);
generation_count = 0

while true
  pp population.individuals.sort_by(&:fitness).reverse

  generation_count += 1

  puts "Generation: #{generation_count}
  Fittest: #{population.fittest_individual.options}
  Fitness: #{population.fittest_individual.fitness}
  Total Fitness: #{population.individuals.map(&:fitness).reduce(0, &:+)}"

  population = evolve_population(population)
end
~~~

# Sample Run

Run 1

~~~
Generation: 1 Fittest: -g -e none -f 40 -o 10  -t 25 -s 0.18 -S 155 -a 0.94 -T Fitness: 0 Total Fitness: 0
Generation: 2 Fittest: -g -e stretch -f 46 -o 8 -u -t 43 -s 0.97 -S 53 -a 0.82  Fitness: 187 Total Fitness: 567
Generation: 3 Fittest: -g -e stretch -f 46 -o 8 -u -t 43 -s 1.02 -S 53 -a 1.02  Fitness: 192 Total Fitness: 1479
Generation: 4 Fittest: -g -e stretch -f 46 -o 10 -u -t 25 -s 1.02 -S 53 -a 0.2  Fitness: 195 Total Fitness: 1894
Generation: 5 Fittest: -g -e stretch -f 46 -o 8 -u -t 28 -s 1.02 -S 43 -a 1.02 -T Fitness: 199 Total Fitness: 1915
Generation: 6 Fittest: -g -e stretch -f 46 -o 8 -u -t 28 -s 1.02 -S 43 -a 1.02 -T Fitness: 199 Total Fitness: 1938
Generation: 7 Fittest: -g -e stretch -f 46 -o 8 -u -t 28 -s 1.07 -S 43 -a 1.02 -T Fitness: 201 Total Fitness: 1964
Generation: 8 Fittest: -g -e stretch -f 46 -o 8 -u -t 28 -s 1.07 -S 43 -a 1.02 -T Fitness: 201 Total Fitness: 1974
Generation: 9 Fittest: -g -e stretch -f 46 -o 8 -u -t 28 -s 1.07 -S 43 -a 1.02 -T Fitness: 201 Total Fitness: 2001
Generation: 10 Fittest: -g -e stretch -f 46 -o 8 -u -t 28 -s 1.07 -S 43 -a 1.02 -T Fitness: 201 Total Fitness: 1986

-------------------- Final output --------------------

”on“-

’ 5,135.}w 119$ Elm: l‘llpil/nytimsj151mb?

‘9‘ ncmc \‘

-vw-wChinavF-urtheﬂlfightensﬁrip on tlielpternet. . »

- ~-~-.~a- . ‘0'“ -“-.-

.0-

8, mom Moons ‘ we 23.3315 “’ . t
ill-2U lKG - ding Yuechen. the founder of an lntemet start-up here in the
Chinese capital. has no interest in os‘erthrowing the Communist Party. 3‘“
these days she finds herself cursing the nation‘s smothering cyberpoliw as
she tries - and fails — to browse photo‘sbaring websites like Flickr and
struggles to stay in touch with the Facebook friends she has made during
trips to France. India and Singapore. ~

Cmail has become almost impossible to use here. and in recent weeks
the authorities have gummed up Astrill, the software Ms. J ing and countless
otltws‘depeneled on to circu nWerrulieJutetnet restrictionsthgtt Milt!
security analysts refer to as the Great Firewall.

By interfering with “trill and several other popular virtual private
networks. or \'.P..\'.s. the government has complicated the lites of Chinese
astronomers seeking the latest scientiﬁc data from abroad, graphic
designers shopping for clip art on Shutterstoclt and students submitting
online applications to American universities.

"lf it was legal to protest and throw rotten eggs on the street. l'd
deﬁnitely be up for that.” Ms. Jing. 25, said.

China has long had some of the world's most onerous Internet

- .rtstricttins. gut until new. the authorities had effectively tolerated the
proliferation of V.P.N.s'as a lifeline for millions of pcoplejror‘n a. -_
archaeologists to foreign investors, who rely heavily on less-fettertd access
to the Internet.

But earlier this week. after a number of V.P.N. companies, including
StrongVPN and Golden Frog, complained that the Chinese government had
disrupted their seniors with unprecedented sophistimtion. a senior official
for the ﬁrst time acknowledged its hand in the attacks and implicitly

s—c
~~~

Run 2

~~~
Generation: 1 Fittest: -g -e none -f 28 -o 0  -t 36 -s 0.37 -S 84 -a 0.52  Fitness: 0 Total Fitness: 0
Generation: 2 Fittest: -g -e none -f 26 -o 9  -t 36 -s 0.0 -S 120 -a 0.91  Fitness: 173 Total Fitness: 272
Generation: 3 Fittest: -g -e stretch -f 26 -o 9  -t 33 -s 0.0 -S 40 -a 0.24  Fitness: 191 Total Fitness: 1040
Generation: 4 Fittest: -g -e stretch -f 26 -o 9  -t 33 -s 0.0 -S 40 -a 0.24  Fitness: 191 Total Fitness: 1656
Generation: 5 Fittest: -g -e stretch -f 24 -o 9  -t 33 -s 0.0 -S 40 -a 0.04 -T Fitness: 202 Total Fitness: 1644
Generation: 6 Fittest: -g -e stretch -f 24 -o 9  -t 33 -s 0.0 -S 40 -a 0.04 -T Fitness: 202 Total Fitness: 1620
Generation: 7 Fittest: -g -e stretch -f 24 -o 9  -t 33 -s 0.0 -S 40 -a 0.04 -T Fitness: 202 Total Fitness: 1911
Generation: 8 Fittest: -g -e stretch -f 24 -o 9  -t 33 -s 0.0 -S 40 -a 0.04 -T Fitness: 202 Total Fitness: 1885
Generation: 9 Fittest: -g -e stretch -f 24 -o 9  -t 33 -s 0.0 -S 40 -a 0.04 -T Fitness: 202 Total Fitness: 1752
Generation: 10 Fittest: -g -e stretch -f 24 -o 9  -t 33 -s 0.0 -S 40 -a 0.04 -T Fitness: 202 Total Fitness: 1929

-------------------- Final output --------------------
-v-—..

'1

" “'-... _.-

{Iintﬁl‘liw \

. a 8' \ll:\:
“T1“:I'QA 1

Ebtﬁvfw york Crimes httpgv‘,’nytims} 15.735”!

ASIA PAC! "C

Chinaﬁurther; Tightensﬁrip on the Internet

Br AND .xEW JACOBS J\.". 2’, 20!! \
BEIJING - .ling ‘r'ueehen. the founder of an Internet start-up here in the
Chinese capital. has no interest in overthrowing the Communist Party. But
these days she ﬁnds herself cursing the nation's smothering, cybeqmlice as
she tries — and fails — to browse photo-sharing websites like lilickr and
struggles to stay in touch with the Facehool; friends she has made during:
trips to France. India and Singapore.

0 mail has Immune almost impossible to use here, and in recent weeks
the authorities have gununed up kstrill, the softmrre Ms. Jim: and countless
utlterwdependerl on to cir‘eLurmL ut. tlteluteruet restrictions lit rt igilt'rn
seeru‘ity analysts refer to as the Great I irewall. ’ .

By interfering with Astrill and several other popular virtual private
networks. or \'.I’.N.s. the government has complicated the lives of Chinese
astronomers seeking the latest scientiﬁc data from abroad. graphic
designers shopping for clip art on Shutterstock and students submitting
onliue applications to Arncrimn universities.

'If it was legal to protest and throw rotten eggs on the street, I'd
deﬁnitely be up for that.“ Ms. Jinx. 25, said.

China has long had some of the world's most onerous Internet
restrictions. But until no as the authorities had effectix eh tolerated the
proliferation of V l’.N. s as a lifeline for millions of people. front x. --
archaeologists to foreign rnv estors, \\ ho rely heavily on lees-fettered access
to the Internet.

But earlier this week. after a number of V. I’.N. companies, includin}.
StmngVPN and Golden Frog. complained that the Chine: ese gov eminent had

disrupted tl eirs eniCes \sith unprecedented sophistication. a Senior official

for the tint time acI-rnouledged its hand in the atta cits and implicitly
~~~


Almost readable! If you're curious, the final images look like this:

- Run1: [smartphonefinal.jpg](/assets/images/smartphonefinal1.jpg)
- Run2: [smartphonefinal.jpg](/assets/images/smartphonefinal2.jpg)

I found it interesting that while they had similar scores, they got different words correct.
It's definitely not a perfect solution, it still has many errors and takes a long time. Commerical services like [OCRSpace](https://ocr.space/) blow it away in terms of speed and accuracy.


# Issues & Improvements

## Current Issues
- Local minima
  - I ran into this a few times while testing. The high mutation rate reduces the chance of this happening, but it's something to be aware of.
- Speed
  - It is slow!

## Potential Improvements
- Iteration time
  - Speed up image transformations (GPU processing, switch to graphicsmagick, distributed processing)
  - Speed up tesseract (GPU processing, distributed processing, use another OCR software)
- Dictionary/fitness function
  - Add penalties
  - Add more words to the dictionary (domain specific, personal names, company names, etc.)
  - Use regex for numbers, email addresses, URLs, etc. if relevant.
- Tesseract options as genes [see for an example of tuning tesseract](https://mlichtenberg.wordpress.com/2015/11/04/tuning-tesseract-ocr/)
- Postprocessing text [example algorithm in here](http://www.cs.bgsu.edu/MCURCSM/proceedings/A-1.pdf)
