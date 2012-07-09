class Match 
  attr_accessor :candidates, :programs

  def initialize
    super 

    #candidates
    c_anderson = Candidate.new("Anderson")
    c_brown = Candidate.new("Brown")
    c_chen = Candidate.new("Chen")
    c_davis = Candidate.new("Davis")
    c_eastman = Candidate.new("Eastman")
    c_ford = Candidate.new("Ford")
    c_garcia = Candidate.new("Garcia")
    c_hassan = Candidate.new("Hassan")

    #programs
    p_mercy = Program.new("Mercy", 2)
    p_city = Program.new("City", 2)
    p_general = Program.new("General", 2)
    p_state = Program.new("State", 2)

    #candidate ranklists
    c_anderson.ranklist = [p_city]
    c_brown.ranklist = [p_city, p_mercy]
    c_chen.ranklist = [p_city, p_mercy]
    c_davis.ranklist = [p_mercy, p_city, p_general, p_state]
    c_eastman.ranklist = [p_city, p_mercy, p_state, p_general]
    c_ford.ranklist = [p_city, p_general, p_mercy, p_state]
    c_garcia.ranklist = [p_city, p_mercy, p_state, p_general]
    c_hassan.ranklist = [p_state, p_city, p_mercy, p_general]

    #program ranklists
    p_mercy.ranklist = [c_chen, c_garcia]
    p_city.ranklist = [c_garcia, c_hassan, c_eastman, c_anderson, c_brown, c_chen, c_davis, c_ford]
    p_general.ranklist = [c_brown, c_eastman, c_hassan, c_anderson, c_chen, c_davis, c_garcia]
    p_state.ranklist = [c_brown, c_eastman, c_anderson, c_chen, c_hassan, c_ford, c_davis, c_garcia]
  end # initialize


  class Candidate
    attr_accessor :name, :current_rank_counter, :ranklist, :ranklistcounter, :tentmatch

    def initialize(name)
      super
      @ranklistcounter = 0
      @name = name
    end #initialize

  end #class Candidate


  class Program
    attr_accessor :name, :spots, :ranklist, :tentmatcharray

    def initialize(name, spots)
      super
      @name = name
      @spots = spots
    end #initialize

  end #class Program




  def printList

    ObjectSpace.each_object.select{|obj| obj.class == Program}.each do |v|
      puts v.spots
    end  

  end #createMatch


  def RunTest

    # go through all Programs
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

  end # getFirstMatches

end #class Match


a = Match.new

a.RunTest







