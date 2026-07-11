<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="github" fetch="https://github.com" />
  <project name="{{DEVICE_REPO}}" path="device/{{BRAND}}/{{DEVICE}}" remote="github" revision="{{BRANCH}}" />
  <project name="{{KERNEL_REPO}}" path="kernel/{{BRAND}}/{{DEVICE}}" remote="github" revision="{{BRANCH}}" />
  <project name="{{VENDOR_REPO}}" path="vendor/{{BRAND}}/{{DEVICE}}" remote="github" revision="{{BRANCH}}" />
</manifest>
