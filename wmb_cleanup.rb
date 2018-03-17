#!ruby
require 'optparse'
require 'yaml'
require_relative 'lib/bayonetta.rb'
include Bayonetta

$options = {
  :vertexes => false,
  :bones => false,
  :textures => false,
  :cleanup_mat => false,
  :cleanup_mat_sizes => false,
  :maximize_mat_sizes => false,
  :delete_bones => nil,
  :offsets => false,
  :fix => false,
  :swap => nil,
  :swap_meshes => nil,
  :delete_meshes => nil,
  :merge_meshes => nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: wmb_cleanup.rb target_file [options]"

  opts.on("-b", "--[no-]bones", "Cleanup bones") do |bones|
    $options[:bones] = bones
  end

  opts.on("-v", "--[no-]vertexes", "Cleanup vertexes") do |vertexes|
    $options[:vertexes] = vertexes
  end

  opts.on("-o", "--[no-]remove-batch-offsets", "Remove batch vertex offsets") do |o|
    $options[:offsets] = o
  end

  opts.on("-f", "--[no-]fix-ex-data", "Put normal map u v in ex data") do |fix|
    $options[:fix] = fix
  end

  opts.on("-e", "--swap-endianness", "Swap endianness") do |swap|
    $options[:swap] = swap
  end

  opts.on("--duplicate-meshes=MESHLIST", "Duplicate specified meshes") do |mesh_list|
    $options[:duplicate_meshes] = eval(mesh_list).to_a
  end

  opts.on("-s", "--swap-meshes=MESHHASH", "Swap specified meshes") do |mesh_hash|
    $options[:swap_meshes] = eval(mesh_hash).to_h
  end

  opts.on("--merge-meshes=MESHHASH", "Merge specified meshes") do |mesh_hash|
    $options[:merge_meshes] = eval(mesh_hash).to_h
  end

  opts.on("-m", "--delete-meshes=MESHLIST", "Delete specified meshes") do |mesh_list|
    $options[:delete_meshes] = eval(mesh_list).to_a
  end

  opts.on("-d", "--delete-bones=BONELIST", "Delete specified bones") do |bone_list|
    $options[:delete_bones] = eval(bone_list).to_a
  end

  opts.on("-t", "--[no-]textures", "Cleanup textures") do |textures|
    $options[:textures] = textures
  end

  opts.on("-c", "--cleanup-materials", "Cleanup materials") do |cleanup_mat|
    $options[:cleanup_mat] = cleanup_mat
  end

  opts.on("--cleanup-material-sizes", "Cleanup material sizes") do |cleanup_mat_sizes|
    $options[:cleanup_mat_sizes] = cleanup_mat_sizes
  end

  opts.on("--maximize-material-sizes", "Maximize material sizes") do |cleanup_mat_sizes|
    $options[:maximize_mat_sizes] = cleanup_mat_sizes
  end

  opts.on("--scale=SCALE", "Scales the model by a factor") do |scale|
    $options[:scale] = scale.to_f
  end

  opts.on("--shift=SHIFT_vector", "Shifts the model") do |shift|
	$options[:shift] = eval(shift).to_a
  end
  
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
  
end.parse!


input_file = ARGV[0]

raise "Invalid file #{input_file}" unless File::file?(input_file)
Dir.mkdir("wmb_output") unless Dir.exist?("wmb_output")
Dir.mkdir("wtb_output") unless Dir.exist?("wtb_output")
wmb = WMBFile::load(input_file)
wmb.scale($options[:scale]) if $options[:scale]
wmb.shift(*($options[:shift])) if $options[:shift]
wmb.duplicate_meshes($options[:duplicate_meshes]) if $options[:duplicate_meshes]
wmb.swap_meshes($options[:swap_meshes]) if $options[:swap_meshes]
wmb.merge_meshes($options[:merge_meshes]) if $options[:merge_meshes]
wmb.delete_meshes($options[:delete_meshes]) if $options[:delete_meshes]
wmb.cleanup_bones if $options[:bones]
wmb.cleanup_vertexes if $options[:vertexes]
wmb.remove_batch_vertex_offsets if $options[:offsets]
wmb.fix_ex_data if $options[:fix]
wmb.delete_bones($options[:delete_bones]) if $options[:delete_bones]
wmb.cleanup_materials if $options[:cleanup_mat]
wmb.cleanup_material_sizes if $options[:cleanup_mat_sizes]
wmb.maximize_material_sizes if $options[:maximize_mat_sizes]
wmb.cleanup_textures(input_file) if $options[:textures]
wmb.renumber_batches
wmb.recompute_layout
wmb.dump("wmb_output/"+File.basename(input_file), $options[:swap] ? !wmb.was_big? : wmb.was_big? )
