from django.conf.urls import include, url
from django.contrib import admin

urlpatterns = [
            url(r'^fmp/', include('fmp.urls')),
                url(r'^admin/', include(admin.site.urls)),
                ]
