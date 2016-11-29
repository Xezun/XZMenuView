
Pod::Spec.new do |s|
    s.name         = 'XZMenuView'
    s.version      = '1.0.0'
    s.summary      = 'An iOS Development Library'
    s.homepage     = 'https://github.com/mlibai'
    s.license      = 'MIT'
    s.authors      = {"mlibai" => "mlibai@163.com"}
    s.source       = { :git => "https://github.com/mlibai/#{s.name}.git", :tag => "#{s.version}" }
    
    s.platform     = :ios, '7.0'
    s.requires_arc = true

    s.public_header_files = 'XZMenuView/*.h'
    s.source_files        = 'XZMenuView/*.{h,m}'
    # s.resource            = '#{s.name}/#{s.name}.bundle'
end
