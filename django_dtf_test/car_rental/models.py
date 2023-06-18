from django.db import models


class Car(models.Model):
    make = models.CharField(max_length=100)
    model = models.CharField(max_length=100)
    year = models.IntegerField()

    def __str__(self):
        return f'{self.make} {self.model} ({self.year})'


class Rental(models.Model):
    car = models.ForeignKey(Car, on_delete=models.CASCADE, related_name='rentals')
    customer_name = models.CharField(max_length=100)
    rental_date = models.DateField()
    return_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f'{self.car} - {self.customer_name}'
