from .views import CarViewSet, RentalViewSet
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'cars', CarViewSet, basename='car')
router.register(r'rentals', RentalViewSet, basename='rental')

urlpatterns = router.urls
