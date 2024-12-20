import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    @IBOutlet weak var cameraView: UIView!

    let captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        addCaptureButton()
    }

    func setupCamera() {
        captureSession.sessionPreset = .photo
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("카메라를 찾을 수 없습니다.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = cameraView.bounds
            cameraView.layer.addSublayer(previewLayer!)

            // 백그라운드 스레드에서 startRunning 호출
                    DispatchQueue.global(qos: .background).async {
                        self.captureSession.startRunning()
                        print("✅ captureSession.startRunning() 호출 완료")
                    }
        } catch {
            print("카메라 설정 중 오류 발생: \(error.localizedDescription)")
        }
    }

    func addCaptureButton() {
        let captureButton = UIButton(type: .system)
        
        // 타이틀 제거
        captureButton.setTitle("", for: .normal)
        
        // 배경 색상 및 둥근 모양 설정
        captureButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        captureButton.layer.cornerRadius = 35  // 버튼을 둥글게 만들기 위해 반지름을 설정
        captureButton.clipsToBounds = true

        // Auto Layout 설정
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(captureButton)

        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            captureButton.widthAnchor.constraint(equalToConstant: 70),  // 버튼 크기 설정
            captureButton.heightAnchor.constraint(equalToConstant: 70)
        ])

        // 버튼 클릭 이벤트 연결
        captureButton.addTarget(self, action: #selector(capturePhoto(_:)), for: .touchUpInside)
    }

    @objc func capturePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        print("사진이 저장되었습니다.")
    }
}

