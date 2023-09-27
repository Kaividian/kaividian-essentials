# The SaveData module is used to manipulate save data. It contains the {Value}s
# that make up the save data and {Conversion}s for resolving incompatibilities
# between Essentials and game versions.
# @see SaveData.register
# @see SaveData.register_conversion

module SaveData

  @@save_index = 0

  def self.getSaveIndex
    return @@save_index
  end

  def self.setSaveIndex(i)
    @@save_index = i
  end

  # Contains the file paths of the save files.
  FILE_PATHS = lambda do
    retVal = []
    for i in 0..Settings::ALLOWED_SAVE_FILES do
      if File.directory?(System.data_directory)
        retVal.append(System.data_directory + "/Game" + i.to_s + ".rxdata")
      else
        retVal.append("./Game" + i.to_s + ".rxdata")
      end
    end
    retVal
  end.call

  # @return [Boolean] whether the save file exists
  def self.exists?(file_index)
    Console.echo_h1(Settings::ALLOWED_SAVE_FILES)
    return File.file?(FILE_PATHS[file_index])
  end

  # Fetches the save data from the given file.
  # Returns an Array in the case of a pre-v19 save file.
  # @param file_path [String] path of the file to load from
  # @return [Hash, Array] loaded save data
  # @raise [IOError, SystemCallError] if file opening fails
  def self.get_data_from_file(file_path)
    validate file_path => String
    save_data = nil
    File.open(file_path) do |file|
      data = Marshal.load(file)
      if data.is_a?(Hash)
        save_data = data
        next
      end
      save_data = [data]
      save_data << Marshal.load(file) until file.eof?
    end
    return save_data
  end

  # Fetches save data from the given file. If it needed converting, resaves it.
  # @param file_path [String] path of the file to read from
  # @return [Hash] save data in Hash format
  # @raise (see .get_data_from_file)
  def self.read_from_file(file_path)
    validate file_path => String
    save_data = get_data_from_file(file_path)
    save_data = to_hash_format(save_data) if save_data.is_a?(Array)
    if !save_data.empty? && run_conversions(save_data)
      File.open(file_path, "wb") { |file| Marshal.dump(save_data, file) }
    end
    return save_data
  end

  # Compiles the save data and saves a marshaled version of it into
  # the given file.
  # @param file_path [String] path of the file to save into
  # @raise [InvalidValueError] if an invalid value is being saved
  def self.save_to_file(file_path)
    validate file_path => String
    save_data = self.compile_save_hash
    File.open(file_path, "wb") { |file| Marshal.dump(save_data, file) }
  end

  # Deletes the save file (and a possible .bak backup file if one exists)
  # @raise [Error::ENOENT]
  def self.delete_file(file_index)
    File.delete(FILE_PATHS[file_index])
    File.delete(FILE_PATHS[file_index] + ".bak") if File.file?(FILE_PATHS[file_index] + ".bak")
  end

  # Converts the pre-v19 format data to the new format.
  # @param old_format [Array] pre-v19 format save data
  # @return [Hash] save data in new format
  def self.to_hash_format(old_format)
    validate old_format => Array
    hash = {}
    @values.each do |value|
      data = value.get_from_old_format(old_format)
      hash[value.id] = data unless data.nil?
    end
    return hash
  end
end
