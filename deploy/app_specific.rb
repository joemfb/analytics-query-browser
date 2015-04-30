require 'json'

# NOTE: tested with MarkLogic 7

class ServerConfig

  alias_method :original_deploy_modules, :deploy_modules

  def deploy_modules
    # if @properties['ml.deploy-include-packages']
      deploy_packages
    # end

    original_deploy_modules
  end

  alias_method :original_clean_modules, :clean_modules

  def clean_modules
    # if @properties['ml.packages-module-locations']
      delete_package_bindings
    # end

    original_clean_modules
  end

  def deploy_packages
    bindings = {}
    packages = Dir.glob( Dir.pwd + '/mlpm_modules/*' )

    packages.each do |package|
      next if File.file? package

      deploy_package_src package
      package_bindings = get_package_module_namespaces(package)

      # if @properties['ml.packages-module-locations']
        # filter duplicate bindings
        package_bindings.each do |package_binding|
          uri = package_binding[ "namespace-uri" ]
          path = package_binding[ "location" ]
          if bindings.has_key? package_binding[ "location" ]
            puts "WARNING: duplicate bindings for #{ uri }"
            puts "\texisting: #{ bindings[ uri ] }"
            puts "\tnew:\t  #{ path }"
          else
            bindings[ uri ] = package_binding
          end
        end
      # end
    end

    packages.each do |package|
      next if File.file? package
      deploy_package_rest package
    end

    # if @properties['ml.packages-module-locations']
      create_package_bindings bindings
    # end

    puts "deployed #{ packages.length } packages"
    puts "configured #{ bindings.keys.length } module namespace bindings"
  end

  def deploy_package_src(path)
    ignore = [
      path + "/rest-api",
      path + "/mlpm.json",
      path + "/LICENSE",
      path + "/CHANGELOG.md",
      path + "/README.md",
      path + "/README.mdown"
    ]

    src_permissions = permissions(@properties['ml.app-role'], Roxy::ContentCapability::ER)

    if ['rest', 'hybrid'].include? @properties["ml.app-type"]
      src_permissions.push permissions('rest-admin', Roxy::ContentCapability::RU)
      src_permissions.push permissions('rest-extension-user', Roxy::ContentCapability::EXECUTE)
      src_permissions.flatten!
    end

    load_data path,
              :remove_prefix => Dir.pwd,
              :ignore_list => ignore,
              :permissions => src_permissions,
              :db => @properties['ml.modules-db'],
              :load_html_as_xml => @properties['ml.load-html-as-xml'],
              :load_js_as_binary => @properties['ml.load-js-as-binary'],
              :load_css_as_binary => @properties['ml.load-css-as-binary']
  end

  def get_package_module_namespaces(path)
    line_regex = /^\s*module\s+namespace\s+[a-z]+\s*=\s*"(.+)";\s*$/
    bindings = []

    # TODO confirm reject
    Dir.glob(path + "/**/*.{xq,xqy,xql,xqm}").reject{ |f| f['rest-api'] }.each do |file|
      next if File.directory? file
      line = File.foreach(file).find { |l|  l.match /^\s*module/ }

      if line =~ line_regex
        bindings << {
          "namespace-uri" => line.match(line_regex).captures[0],
          "location" => file.gsub(Dir.pwd, "")
        } if line
      end
    end

    bindings
  end

  def create_package_bindings(bindings)
    r = execute_query %Q!
xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";
declare namespace gr = "http://marklogic.com/xdmp/group";

(:
   ML8: xdmp:from-json(xdmp:unquote())
   TODO:
     use /manage/v2/server/${name}/properties
:)
declare variable $json := xdmp:from-json('#{ bindings.values.to_json }');
declare variable $appserver-name := "#{ @properties['ml.app-name'] }";
declare variable $group-name := "#{ @properties['ml.group'] }";

declare option xdmp:mapping "false";

let $config := admin:get-configuration()
let $appserver-id :=
  admin:appserver-get-id($config,
    admin:group-get-id($config, $group-name), $appserver-name)

let $existing-locations := admin:appserver-get-module-locations($config, $appserver-id)
let $locations :=
  for $map in json:array-values($json)
  let $uri := map:get($map, "namespace-uri")
  where fn:not(fn:exists(($existing-locations[gr:namespace-uri eq $uri])))
  return $map

where fn:exists($locations)
return
  admin:save-configuration-without-restart(
    fn:fold-left(
      function($config, $location) {
        (: TODO: check existing, blacklist :)
        admin:appserver-add-module-location($config, $appserver-id,
          admin:group-module-location( map:get($location, "namespace-uri"), map:get($location, "location") ))
      },
      $config,
      $locations))
    !
  end

  def delete_package_bindings()
    r = execute_query %Q!
xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

declare variable $appserver-name := "#{ @properties['ml.app-name'] }";
declare variable $group-name := "#{ @properties['ml.group'] }";

declare option xdmp:mapping "false";

let $config := admin:get-configuration()
let $appserver-id :=
  admin:appserver-get-id($config,
    admin:group-get-id($config, $group-name), $appserver-name)

let $existing-locations := admin:appserver-get-module-locations($config, $appserver-id)
where fn:exists($existing-locations)
return
  admin:save-configuration-without-restart(
    admin:appserver-delete-module-location($config, $appserver-id, $existing-locations))
    !
  end

  def deploy_package_rest(path)
    if File.directory?(path + "/rest-api")
      if File.directory?(path + "/rest-api/ext")
        puts "deploying REST extensions for " + path
        mlRest.install_extensions(path + "/rest-api/ext")
      end

      if File.directory?(path + "/rest-api/transforms")
        puts "deploying REST transformations for " + path
        mlRest.install_transforms(path + "/rest-api/transforms")
      end
    end
  end

end