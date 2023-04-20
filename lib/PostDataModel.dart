class PostDataModel {
  final String title, content, slug, image;
  final int id;

  PostDataModel(this.id, this.title, this.content, this.slug, this.image);

  factory PostDataModel.fromMap(Map<String, dynamic> json) => new PostDataModel(
      json['id'],
      json['title'],
      json['content'],
      json['slug'],
      json['image']
  );

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'title' : title,
      'content' : content,
      'slug' : slug,
      'image' : image,
    };
  }

}