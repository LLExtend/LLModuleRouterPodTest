
Pod::Spec.new do |spec|

  # 库名称
  spec.name         = "LLModuleRouterPodTest"
  
  # 版本号
  spec.version      = "0.1.0"
  
  # 简短描述
  spec.summary      = "模块化开发路由"

  # 开源库描述
  spec.description  = "模块化开发push、pop、present中间件"
  
  # 开源库地址
  spec.homepage     = "https://github.com/LLExtend/LLModuleRouterPodTest.git"

  # 开源协议
  spec.license      = { :type => "MIT", :file => "LICENSE" }

    
  # 开源库作者
  spec.author             = { "zhaoyulong" => "zhaoyulong@fanjia.net" }

  # 社交网址
  # spec.social_media_url   = "https://twitter.com/zhaoyulong"

  # build的平台
  spec.platform     = :ios

  # 最低开发
  # spec.ios.deployment_target = "9.0"

  # 开源库Github路径
  spec.source       = { :git => "https://github.com/LLExtend/LLModuleRouterPodTest.git", :tag => "#{spec.version}" }

  # 开源库资源文件
  spec.source_files  = "LLModuleRouter", "LLModuleRouter/**/*.{h,m}"
  spec.exclude_files = "LLModuleRouter/Exclude"


end
