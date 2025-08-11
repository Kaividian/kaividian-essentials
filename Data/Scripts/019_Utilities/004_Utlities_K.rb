class Region
    attr_accessor :region_name
    attr_accessor :id
    attr_accessor :badges

    class Badge
        attr_accessor :id
        attr_accessor :name
        attr_accessor :owned
    end
end