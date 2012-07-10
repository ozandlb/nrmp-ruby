class Match 

  def initialize(candinfo, proginfo)
    super 

    #initialize candidates
    @candidates = []

    candinfo.each_index do |x|
      @candidates[x] = Candidate.new(candinfo[x][0])
    end #for candidates


    #initialize programs
    @programs = []

    proginfo.each_index do |x|
      @programs[x] = Program.new(proginfo[x][0], proginfo[x][1])
    end #do programs


    #initialize candidates' ranklists
    candinfo.each_index do |x|

      candinfo[x][1].each_index do |y|

        ObjectSpace.each_object.select{|obj| obj.class == Program && obj.name == candinfo[x][1][y]}.each do |prog|
          @candidates[x].ranklist.push(prog)
          break
        end #each_object Program

      end #do
      
    end #candidates do


    #initialize programs' ranklists
    proginfo.each_index do |x|

      proginfo[x][2].each_index do |y|

        ObjectSpace.each_object.select{|obj| obj.class == Candidate && obj.name == proginfo[x][2][y]}.each do |cand|
          @programs[x].ranklist.push(cand)
          break
        end #each_object Candidate

      end #do   
    end #candidates do

  end # initialize



  class Candidate
    attr_accessor :name, :current_rank_counter, :ranklist, :tentmatch


    def initialize(name)
      super
      @name = name
      @ranklist = []
    end #initialize


    def FindMatch

      # go through rank list starting from the beginning
      @ranklist.each_with_index.map do |prog, i|

        puts "\n#{@name} seeking match at #{prog.name}."

        # run Match
        @matchresult = prog.TryMatch(self)

        # if candidate is able to find a match at the program, add to tentmatch
        if @matchresult.class == Candidate || @matchresult == true

          puts "#{@name} tentatively matched with #{prog.name}."
          @tentmatch = prog

          # if popped candidate is returned, find match for candidate
          if @matchresult.class == Candidate
            puts "\nFinding new match for #{@matchresult.name}."
            @matchresult.FindMatch
          end #if  

          return true

        elsif @matchresult == false
          puts "#{name} is not matched at #{prog.name}."
          #@tentmatch = nil

        end #if result of matchresult

      end # each ranklist program

      puts "Reached end of #{name}'s ranklist, #{name} remains unmatched."

    end #FindMatch


  end #class Candidate



  class Program
    attr_accessor :name, :spots, :ranklist, :tentmatcharray


    def initialize(name, spots)
      super
      @name = name
      @spots = spots
      @tentmatcharray = []
      @ranklist = []
    end #initialize



    def TryMatch(candidate)

      # reject if candidate is not on program's ranklist
      if ranklist.index(candidate).nil? == true
        puts "#{candidate.name} is not on #{name}'s ranklist."
        return false
      end #if

      puts "#{candidate.name} is on #{self.name}'s ranklist."

      print "#{self.name} has #{self.spots} spots in total, #{tentmatcharray.length} of which are tentatively taken: "
      self.PrintTentMatchArray

      # if the ranklist has empty spots 
      if @tentmatcharray.length < @spots

        # add to the array
        @tentmatcharray.push(candidate)

        puts "#{candidate.name} added to #{name}'s tenative match list."

        self.SortTentMatchArray
        return true


        # if program doesn't have empty spots, 
        # check if the matched candidates' ranking is lower than active candidate ranking
      elsif @ranklist.index(candidate) < @ranklist.index(@tentmatcharray.last)
        puts "#{candidate.name}(#{@ranklist.index(candidate)}) is higher ranked by #{name} than #{@tentmatcharray.last.name}(#{@ranklist.index(@tentmatcharray.last)})."
        # pop off lowest candidate  
        @poppedcand = @tentmatcharray.last
        puts "#{@tentmatcharray.last.name} removed from #{@name}'s tentative match list."
        @tentmatcharray.pop

        # add to and sort tentmatcharray
        puts "#{candidate.name} added to #{name}'s tentative match list."
        @tentmatcharray.push(candidate)
        self.SortTentMatchArray

        #run match on popped off candidate
        return @poppedcand

      else 
        print "#{candidate.name}(#{ranklist.index(candidate)}) is lower ranked than other candidates on #{name}'s tentative match list: "
        self.PrintTentMatchArray
        return false

      end #if

    end #TryMatch(candidate)



    def SortTentMatchArray
      if @tentmatcharray.length > 1
        @tentmatcharray.sort!{ |a,b| @ranklist.index(a) <=> @ranklist.index(b) }
        print "Sort #{name}'s tentative match list: "
        self.PrintTentMatchArray
      end
    end #SortTentMatchArray



    def PrintTentMatchArray
      @tentmatcharray.each { |x| print "#{x.name}(#{@ranklist.index(x)+1}) " }
      print "\n"
    end #PrintTentMatchArray



  end #class Program



  def RunMatch

    # Go through each Candidate
    ObjectSpace.each_object.select{|obj| obj.class == Candidate}.each do |cand|

      cand.FindMatch

    end #each Candidate

    self.PrintResult

  end #RunMatch



  def PrintResult

    # Go through each Candidate

    puts "\n\nFINAL PROGRAM MATCHLIST\n------------------------------"

    ObjectSpace.each_object.select{|obj| obj.class == Program}.each do |prog|

      print "#{prog.name}: "
      prog.tentmatcharray.each_with_index.map { |x, i| print "#{i+1}.#{x.name} " }
      print "\n"
    end # each Program


    puts "\n\nFINAL CANDIDATE RESULTS\n------------------------------"

    ObjectSpace.each_object.select{|obj| obj.class == Candidate}.each do |cand|

      print "#{cand.name}: #{cand.tentmatch == nil ? "Unmatched" : cand.tentmatch.name}"
      print "\n"
    end # each Candidate


  end # PrintResult


end #class Match






candinfo = [   
  ["Anderson", ["City"]],
  ["Brown", ["City", "Mercy"]],
  ["Chen", ["City", "Mercy"]],
  ["Davis", ["Mercy", "City", "General", "State"]],
  ["Eastman", ["City", "Mercy", "State", "General"]],
  ["Ford", ["City", "General", "Mercy", "State"]],
  ["Garcia", ["City", "Mercy", "State", "General"]],
  ["Hassan", ["State", "City", "Mercy", "General"]]
]

proginfo = [
  ["Mercy", 2, ["Chen", "Garcia"]], 
  ["City", 2, ["Garcia", "Hassan", "Eastman", "Anderson", "Brown", "Chen", "Davis", "Ford"]], 
  ["General", 2, ["Brown", "Eastman", "Hassan", "Anderson", "Chen", "Davis", "Garcia"]], 
  ["State", 2, ["Brown", "Eastman", "Anderson", "Chen", "Hassan", "Ford", "Davis", "Garcia"]]
]



a = Match.new(candinfo, proginfo) 

a.RunMatch


