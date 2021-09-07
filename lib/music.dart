class Music{
  late String artiste;
  late String titre;
  late String imagePath;
  late String urlSong;

  Music(String titre , String artiste, String imagePath, String urlSong){
    this.artiste = artiste;
    this.titre = titre;
    this.imagePath = imagePath;
    this.urlSong = urlSong;
  }
}