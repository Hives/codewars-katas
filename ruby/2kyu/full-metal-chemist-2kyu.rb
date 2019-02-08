class Atom
    attr_accessor :element, :id, :bonds

    @@element_details = {
      "H" => [1, 1.0],
      "B" => [3, 10.8],
      "C" => [4, 12.0],
      "N" => [3, 14.0],
      "O" => [2, 16.0],
      "F" => [1, 19.0],
      "Mg" => [2, 24.3],
      "P" => [3, 31.0],
      "S" => [2, 32.1],
      "Cl" => [1, 35.5],
      "Br" => [1, 80.0]
    }

    def initialize(elt, id)
        @element = elt
        @id = id
        @bonds = []
    end

    def to_s
      carbons = []
      hydrogens = []
      oxygens = []
      everything_else = []
      self.bonds.sort { |a, b|
        a.id <=> b.id
      }.sort { |a,b|
        a.element <=> b.element
      }.each { |atom|
        case atom.element
        when "C"
          carbons << "#{atom.element}#{atom.id}"
        when "O"
          oxygens << "#{atom.element}#{atom.id}"
        when "H"
          hydrogens << "#{atom.element}"
        else
          everything_else << "#{atom.element}#{atom.id}"
        end
      }
      bonds = (carbons + oxygens + everything_else + hydrogens).join(",")
      if bonds.size > 0
        "Atom(#{self.element}.#{self.id}: #{bonds})"
      else
        "Atom(#{self.element}.#{self.id})"
      end
    end

    def mutate(element)
      raise InvalidBond if @@element_details[element][0] < @bonds.size
      @element = element
    end

    def valence
      @@element_details[self.element][0]
    end

    def weight
      @@element_details[self.element][1]
    end

    def bond(atom)
      @bonds << atom
    end

    def unbond_h
      @bonds.delete_if { |atom| atom.element == "H" }
    end
    
    def hash() return self.id end                # Do not modify this method
    def ==(o)  return self.id == o.id end        # Do not modify this method
    def eql?(other)  return self == other end    # Do not modify this method

end
    
class Molecule
  attr_accessor :name, :atoms

  def initialize(name="")
    @name = name
    @branches = []
    @atoms = []
    @locked = false
  end

  def brancher(*sizes)
    raise LockedMolecule if @locked == true
    sizes.each do |n|
      branch = []
      n.times do
        branch << create_atom("C")
        bond_atoms(branch[-1], branch[-2]) if branch.size >= 2
      end
      @branches << branch
    end
    self
  end

  def bounder(*bonds)
    raise LockedMolecule if @locked == true
    bonds.each do |bond|
      bond_atoms(@branches[bond[1] - 1][bond[0] - 1], @branches[bond[3] - 1][bond[2] - 1])
    end
    self
  end

  def mutate(*muts)
    raise LockedMolecule if @locked == true
    muts.each do |mut|
      @branches[mut[1] - 1][mut[0] - 1].mutate(mut[2])
    end
    self
  end

  def add(*additions)
    raise LockedMolecule if @locked == true
    additions.each do |addition|
      target = @branches[addition[1] - 1][addition[0] - 1] 
      raise InvalidBond if !(target.valence > target.bonds.size)
      bond_atoms(create_atom(addition[2]), target)
    end
    self
  end

  def add_chaining(carbon, branch, *elements)
    raise LockedMolecule if @locked == true
    target = @branches[branch - 1][carbon - 1]
    chain = []
    while elements.size > 0 do
      chain << Atom.new(elements.shift, @atoms.size + chain.size + 1)
      bond_atoms(chain[-1], chain[-2]) if chain.length >= 2
    end
    bond_atoms(target, chain[0])
    @atoms += chain
    self
  rescue InvalidBond
    raise InvalidBond
    self
  end

  def closer
    raise LockedMolecule if @locked == true
    @locked = true
    @atoms.each do |atom|
      while atom.bonds.size < atom.valence
        bond_atoms(atom, create_atom("H"))
      end
    end
    self
  end

  def unlock
    raise UnockedMolecule if @locked == false
    @locked = false

    @atoms.delete_if { |atom| atom.element == "H" }
    @atoms.each do |atom|
      atom.unbond_h
    end
    @branches.each do |branch|
      branch.delete_if { |atom| atom.element == "H" }
    end
    @branches.delete_if { |branch| branch.size == 0 }
    raise EmptyMolecule if @branches.size == 0

    @atoms.each_with_index { |atom, i| atom.id = i + 1 }

    self
  end

  def formula
    raise UnlockedMolecule if @locked == false
    output = ""
    elements_in_molecule = @atoms.map{ |atom| atom.element }
    ["C", "H", "O", "B", "Br", "Cl", "F", "Mg", "N", "P", "S"].each do |element|
      c = elements_in_molecule.count(element)
      output += element if c == 1
      output += "#{element}#{c}" if c > 1
    end
    output
  end

  def molecular_weight
    raise UnlockedMolecule if @locked == false
    @atoms.sum { |atom| atom.weight }
  end

  def to_s
    @atoms.map { |atom| atom.to_s }.to_s
  end

  private

  def create_atom(element)
    @atoms << Atom.new(element, @atoms.size + 1)
    @atoms[-1]
  end

  def bond_atoms(a, b)
    raise InvalidBond.new if a == b
    raise InvalidBond.new if a.valence == a.bonds.size
    raise InvalidBond.new if b.valence == b.bonds.size
    a.bond(b)
    b.bond(a)
  end


end

class InvalidBond < StandardError
end

class UnlockedMolecule < StandardError
end

class LockedMolecule < StandardError
end

class EmptyMolecule < StandardError
end

#methane = Molecule.new("methane").brancher(1).closer
#m = Molecule.new.brancher(3).bounder([1,1,2,1],[3,1,2,1]).add([2,1,"H"]).closer
#m = Molecule.new.brancher(3).add_chaining(2,1,"O","Mg").closer
m = Molecule.new.brancher(1,2,4).bounder([2,2,1,3]).mutate([1,1,"H"]).closer
puts m.to_s
m.unlock
puts m.to_s
