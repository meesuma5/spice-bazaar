from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Reviews
from .serializers import ReviewUploadSerializer, ReviewEditSerializer

class ReviewUploadView(generics.CreateAPIView):

    serializer_class = ReviewUploadSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class ReviewEditView(APIView):
    permission_classes = [IsAuthenticated]
    
    def put(self, request, review_id):
        try:
            review = Reviews.objects.get(review_id=review_id)

            if review.user != request.user:
                return Response({"error": "You do not have permission to edit this review"}, status=status.HTTP_403_FORBIDDEN)
            
        except Reviews.DoesNotExist:
            return Response({"error": "Review not found"}, status=status.HTTP_404_NOT_FOUND)
            
        serializer = ReviewEditSerializer(review, data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class ReviewDeleteView(APIView):
    permission_classes = [IsAuthenticated]
    
    def delete(self, request, review_id):
        try:
            review = Reviews.objects.get(review_id=review_id)
            if review.user != request.user:
                return Response({"error": "You do not have permission to delete this review"}, status=status.HTTP_403_FORBIDDEN)
            
        except Reviews.DoesNotExist:
            return Response({"error": "Review not found"}, status=status.HTTP_404_NOT_FOUND)
            
        review.delete()
        
        return Response({"message": "Review deleted successfully"}, status=status.HTTP_200_OK)