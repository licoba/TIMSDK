Pod::Spec.new do |spec|
  spec.name         = 'TUIContact'
  spec.version      = '8.6.7019'
  spec.platform     = :ios
  spec.ios.deployment_target = '9.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUIContact'
  spec.dependency 'TUICore'
  spec.dependency 'TIMCommon'
  spec.dependency 'ReactiveObjC'
  spec.requires_arc = true

  spec.source = { :git => './'}
  spec.source_files = '**/*.{h,m,mm,c}'
  
  spec.resource = ['Resources/*.bundle']
  
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => 'Resources/PrivacyInfo.xcprivacy'
  }
end
