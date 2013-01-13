require "rspec"
require "player"
require "tournament"

describe "Tournament" do

  let(:observer) do
    obs = Object.new
    obs.stub(:notify_state)
    obs.stub(:notify_end)
    obs
  end
  let(:options) do
    options = {}
    options[:round_length] = 4
    options[:history_length] = 2
    options[:num_players] = 3
    options[:max_generations] = 10
    options
  end
  let(:tournament) { Tournament.new(observer, options) }
  let(:population) {tournament.instance_eval{@population}}
  let(:players) {population.players}


  describe "select_players_for_round" do

    #let(:couples) {tournament.select_players_for_round}

    before do
      Selector.stub(:pick_small_one).and_return(0,1,0,0,0,1)
      @couples = tournament.select_players_for_round
    end

    it "returns an array of arrays with 2 Players each" do
      @couples.each do |couple|
        couple.size.should == 2
        couple.first.should be_a Player
        couple.last.should be_a Player
      end
    end
    it "gets population.size-1 partners for each player, and the player should not be among them" do
      players.each do |player|
        partners = @couples.select{|couple| couple.first == player }
        partners.size.should == 2
        partners.each{|couple| couple.first.should == player}
        partners.map{|p| p.last}.include?(player).should be_false
      end
      @couples.size.should == 6
    end
    it "selects players based on distance" do
      # selection faked with stubbing of Selector.pick_small_one in Before
      playerA = players[0]
      playerB = players[1]
      playerC = players[2]
      @couples[0].last.should == playerB
      @couples[1].last.should == playerC
      @couples[2].last.should == playerA
      @couples[3].last.should == playerA
      @couples[4].last.should == playerA
      @couples[5].last.should == playerB
    end
  end

  describe "reproduce" do

    context "at least 2 different players within fittest array" do
      let(:fittest) { [population[0], population[1], population[1]] }

      it "replaces the population's players" do
        expect {
          tournament.reproduce(fittest)
        }.to change {tournament.instance_eval{@population.players}}
      end
      it "doesn't change the size of the population" do
        expect {
          tournament.reproduce(fittest)
        }.not_to change {tournament.instance_eval{@population.players.size}}
      end
      it "increments @num_generations by 1" do
        expect {
          tournament.reproduce(fittest)
        }.to change { tournament.instance_eval{@num_generations} }.by(1)
      end
      it "doesn't change the number of players on the Lattice" do
        size_before = UniqLattice.instance.players.size
        tournament.reproduce(fittest)
        UniqLattice.instance.players.size.should == size_before
        # expect goes crazy here for some reasons...
      end
    end

    context "player's within fittest array are all identical" do

      let(:fittest) { (0..population.size-1).map{|i| population[0] } }

      it "replaces the population's players" do
        expect {
          tournament.reproduce(fittest)
        }.to change {tournament.instance_eval{@population.players}}
      end
      it "doesn't change the size of the population" do
        expect {
          tournament.reproduce(fittest)
        }.not_to change {tournament.instance_eval{@population.players.size}}
      end
      it "increments @num_generations by 1" do
        expect {
          tournament.reproduce(fittest)
        }.to change { tournament.instance_eval{@num_generations} }.by(1)
      end
      it "doesn't change the number of players on the Lattice" do
        expect {
          tournament.reproduce(fittest)
        }.not_to change {UniqLattice.instance.players.size}
      end
    end
  end

  describe "play_round" do

    let(:player1) {Player.create(2)}
    let(:player2) {Player.create(2)}
    let(:round_length) {tournament.instance_eval{@round_length}}

    context "both players always cooperate" do

      before do
        Action.stub(:random_action).and_return(Action.cooperative)
      end

      it "sets the score of the first player to @round_length * REWARD" do
        expect{
          tournament.play_round(player1, player2)
        }.to change{player1.score}.from(0).to(round_length * Tournament::REWARD)
      end
      it "sets the score of the second player to @round_length * REWARD" do
        expect{
          tournament.play_round(player1, player2)
        }.to change{player2.score}.from(0).to(round_length * Tournament::REWARD)
      end
      it "updates the history of player 1 with the actions he took" do
        expected_history = (1..4).map{|i| Action.cooperative}
        expect{
          tournament.play_round(player1, player2)
        }.to change{player1.history}.from([]).to(expected_history)
      end
      it "updates the history of player 2 with the actions he took" do
        expected_history = (1..4).map{|i| Action.cooperative}
        expect{
          tournament.play_round(player1, player2)
        }.to change{player2.history}.from([]).to(expected_history)
      end
    end

    context "first players always cooperates, second always cheats" do

      before do
        Action.stub(:random_action).and_return(Action.cooperative)
        player1
        Action.stub(:random_action).and_return(Action.treacherous)
        player2
      end

      it "sets the score of the first player to @round_length * SUCKER" do
        tournament.play_round(player1, player2)
        player1.score.should == round_length * Tournament::SUCKER
      end
      it "sets the score of the second player to @round_length * TEMPTATION" do
        expect{
          tournament.play_round(player1, player2)
        }.to change{player2.score}.from(0).to(round_length * Tournament::TEMPTATION)
      end
      it "updates the history of player 1 with the actions he took" do
        expected_history = (1..4).map{|i| Action.cooperative}
        expect{
          tournament.play_round(player1, player2)
        }.to change{player1.history}.from([]).to(expected_history)
      end
      it "updates the history of player 2 with the actions he took" do
        expected_history = (1..4).map{|i| Action.treacherous}
        expect{
          tournament.play_round(player1, player2)
        }.to change{player2.history}.from([]).to(expected_history)
      end
    end
  end

  describe "private convert_option_keys_to_sym" do
    context "options hash has symbol keys" do
      let(:options) { {a: 1, b: 2, c:3} }
      it "doesn't change the hash" do
        expect{
          tournament.send(:convert_option_keys_to_sym, options)
        }.not_to change{options}
      end
    end
    context "options hash has string keys" do
      let(:options) { {'a' => 1, 'b' => 2, 'c' => 3} }
      it "doesn't change the hash" do
        converted = tournament.send(:convert_option_keys_to_sym, options)
        converted.should == {a: 1, b: 2, c: 3}
      end
    end
  end


  describe "Run a tournament with evolve" do
    let(:observer) do
      class Runner
        def notify_state(population, generation)
          puts "Generation nr #{generation}: Total score is #{population.total_score}"
          sorted_players = population.sort_by{|p| p.score }
          sorted_players[-4..-1].each do |p|
            puts "Score: #{p.score}; #{p.chromosome}"
          end
        end

        def notify_end(population, generation)
          puts "Simulation done:"
          puts "Generation nr #{generation}: Total score is #{population.total_score}"
          sorted_players = population.sort_by{|p| -p.score }
          sorted_players.each do |player|
            puts "Score: #{player.score}  #{player.chromosome}"
          end
        end
      end
      Runner.new
    end
    let(:options) do
      options = {}
      options[:round_length] = 64
      options[:num_players]  = 17
      options[:history_length] = 3
      options[:max_generations] = 21
      options
    end
    it "runs a tournament" do
      tournament = Tournament.new(observer, options)
      tournament.evolve
    end
  end
end

