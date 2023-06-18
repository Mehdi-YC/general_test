from rest_framework import serializers
from .models import Car, Rental


class RentalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rental
        fields = '__all__'


class CarSerializer(serializers.ModelSerializer):
    rentals = RentalSerializer(many=True, read_only=True)

    class Meta:
        model = Car
        fields = '__all__'
