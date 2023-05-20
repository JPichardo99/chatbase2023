class OnbordingContent {
  String? image;
  String? title;
  String? discription;

  OnbordingContent({this.image, this.title, this.discription});
}

List<OnbordingContent> contents = [
  OnbordingContent(
      title: '¡Bienvenido a Chatbase!',
      image: 'assets/onboarding/chat-conversation-laptop.png',
      discription:
          "Podrás conectarte con amigos, familiares y colegas en cualquier momento y en cualquier lugar del mundo"),
  OnbordingContent(
      title: '¡Únete a la conversación!',
      image: 'assets/onboarding/chat-communication-conversation.png',
      discription:
          "Podrás enviar mensajes e imagenes, y conectarte con personas de todo el mundo, "
          "¡Prepárate para una experiencia de chat única!"),
  OnbordingContent(
      title: '¡Comienza a chatear ahora!',
      image: 'assets/onboarding/device-devices-phone.png',
      discription:
          "Podrás iniciar conversaciones, compartir experiencias y hacer nuevos amigos, "
          "¡No esperes más y comienza a chatear ahora!"),
];
