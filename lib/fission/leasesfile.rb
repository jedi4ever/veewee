require 'date'

class Lease
  attr_accessor :name,:mac,:start,:end,:ip

  def initialize(name)
    @name=name
    @ip=name
  end

  def expired?
    @end < DateTime.now
  end
end

class LeasesFile

  attr_reader :leases

  def initialize(filename)
    @filename=filename
    @leases=Array.new
    load
  end

  def load
    @leases=Array.new
    File.open(@filename,"r") do |leasefile|
      lease=nil
      while (line = leasefile.gets)

        line=line.lstrip.gsub(';','')
        case line
        when /^lease/
          @leases << lease unless lease.nil?
          name=line.split(' ')[1]
          lease=Lease.new(name)
        when /^hardware/
          lease.mac=line.split(" ")[2]
        when /^starts/
          lease.start=DateTime.parse(line.split(" ")[2..3].join(" "))
        when /^ends/
          lease.end=DateTime.parse(line.split(" ")[2..3].join(" "))
        end

      end
      @leases << lease unless lease.nil?
    end
    return @leases
  end

  def all_leases
    return @leases
  end

  def current_leases
    hash_list=Hash.new
    @leases.each do |lease|
      hash_list[lease.name]=lease
    end
    collapsed_list=Array.new
    hash_list.each do |key,value|
      collapsed_list << value
    end
    return collapsed_list
  end

  def find_lease_by_mac(mac)
    matches=current_leases.select{|l| l.mac==mac}
    return nil if matches.nil?
    return matches[0]
  end

end
