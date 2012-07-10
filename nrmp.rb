class Match 
  attr_accessor :candidates, :programs, :c_hassan

  def initialize
    super 

    #candidates
    @c_anderson = Candidate.new("Anderson")
    @c_brown = Candidate.new("Brown")
    @c_chen = Candidate.new("Chen")
    @c_davis = Candidate.new("Davis")
    @c_eastman = Candidate.new("Eastman")
    @c_ford = Candidate.new("Ford")
    @c_garcia = Candidate.new("Garcia")
    @c_hassan = Candidate.new("Hassan")

    #programs
    @p_mercy = Program.new("Mercy", 2)
    @p_city = Program.new("City", 2)
    @p_general = Program.new("General", 2)
    @p_state = Program.new("State", 2)

    #candidate ranklists
    @c_anderson.ranklist = [@p_city]
    @c_brown.ranklist = [@p_city, @p_mercy]
    @c_chen.ranklist = [@p_city, @p_mercy]
    @c_davis.ranklist = [@p_mercy, @p_city, @p_general, @p_state]
    @c_eastman.ranklist = [@p_city, @p_mercy, @p_state, @p_general]
    @c_ford.ranklist = [@p_city, @p_general, @p_mercy, @p_state]
    @c_garcia.ranklist = [@p_city, @p_mercy, @p_state, @p_general]
    @c_hassan.ranklist = [@p_state, @p_city, @p_mercy, @p_general]

    #program ranklists
    @p_mercy.ranklist = [@c_chen, @c_garcia]
    @p_city.ranklist = [@c_garcia, @c_hassan, @c_eastman, @c_anderson, @c_brown, @c_chen, @c_davis, @c_ford]
    @p_general.ranklist = [@c_brown, @c_eastman, @c_hassan, @c_anderson, @c_chen, @c_davis, @c_garcia]
    @p_state.ranklist = [@c_brown, @c_eastman, @c_anderson, @c_chen, @c_hassan, @c_ford, @c_davis, @c_garcia]
  end # initialize



  class Candidate
    attr_accessor :name, :current_rank_counter, :ranklist, :ranklistcounter, :tentmatch


    def initialize(name)
      super
      @name = name
      @ranklist = []
    end #initialize


    def FindMatch

      # go through rank list starting from the beginning
      @ranklist.each_with_index.map do |prog, i|

        @ranklistcounter = i
        puts "\n#{name} seeking match at #{prog.name}."

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
          @tentmatch = "Unmatched"

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





  def PrintDetails

    # Go through each Program
    ObjectSpace.each_object.select{|obj| obj.class == Program}.each do |prog|

      candlist = []

      # Go through each Candidate
      ObjectSpace.each_object.select{|obj| obj.class == Candidate}.each do |cand|

        # if the Candidate has ranked the Program AND the Program has ranked the Candidate
        if cand.ranklist.index(prog).nil? == false && prog.ranklist.index(cand).nil? == false

          # Add the candidate to the Program's Candidate array
          candlist.push(cand)
        end # if

      end #each Candidate

      # print each Program's candidate list, ordered by Candidates' ranking of the program
      print "#{prog.name}:  "

      candlist.sort!{ |a,b| prog.ranklist.index(a) <=> prog.ranklist.index(b) }

      candlist.each_with_index.map { |v, index| print "#{prog.ranklist.index(v) + 1}.#{v.name}(#{v.ranklist.index(prog) + 1})  " } 
      print "\n"

    end #each Program

  end # PrintDetails






  def RunMatch

    # Go through each Candidate
    ObjectSpace.each_object.select{|obj| obj.class == Candidate}.each do |cand|

      cand.FindMatch

    end #each Candidate

    self.PrintResult

  end #RunMatch



  def PrintResult

    # Go through each Candidate

    puts "\n\nFINAL MATCHLIST\n********************"

    ObjectSpace.each_object.select{|obj| obj.class == Program}.each do |prog|

      print "#{prog.name}: "
      prog.tentmatcharray.each_with_index.map { |x, i| print "#{i+1}.#{x.name} " }
      print "\n"
    end # each Program

  end # PrintResult




end #class Match





a = Match.new

a.RunMatch

