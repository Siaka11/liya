class HomeOption {
  final String title;
  final String icon;
  final String location;
  final String availability;

  const HomeOption({
    required this.title,
    required this.icon,
     this.location = "Yamoussoukro",
     this.availability = "Ouvert tous les jours",
  });
}