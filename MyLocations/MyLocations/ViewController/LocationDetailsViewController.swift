import CoreData
import CoreLocation
import UIKit

class LocationDetailsViewController: UITableViewController {
    private var date = Date()
    private var image: UIImage? {
        didSet {
            if let image {
                show(image: image)
            }
        }
    }

    var managedObjectContext: NSManagedObjectContext!
    var locationToEdit: Location? {
        didSet {
            guard let location = locationToEdit else {
                return
            }

            descriptionText = location.locationDescription
            categoryName = location.category
            date = location.date
            coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            placemark = location.placemark
        }
    }

    var descriptionText: String = ""

    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var addPhotoLabel: UILabel!

    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var imageView: UIImageView!

    @IBOutlet var imageHeight: NSLayoutConstraint!

    var coordinate = CLLocationCoordinate2D(
        latitude: 0,
        longitude: 0
    )

    var placemark: CLPlacemark?
    var categoryName = "No Category"

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let locationToEdit {
            title = "Edit Location"

            if locationToEdit.hasPhoto {
                if let image = locationToEdit.photoImage {
                    show(image: image)
                }
            }
        }

        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName

        latitudeLabel.text = String(
            format: "%.8f",
            coordinate.latitude
        )
        longitudeLabel.text = String(
            format: "%.8f",
            coordinate.longitude
        )

        if let placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }

        dateLabel.text = format(date: date)

        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )

        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)

        listenForBackgroundNotification()
    }

    @objc private func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        if indexPath != nil
            && indexPath!.section == 0
            && indexPath!.row == 0
        {
            return
        }

        descriptionTextView.resignFirstResponder()
    }

    private func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        addPhotoLabel.text = ""
        imageHeight.constant = 260
        tableView.reloadData()
    }

    private func listenForBackgroundNotification() {
        NotificationCenter.default.addObserver(
            forName: UIScene.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else {
                return
            }

            if self.presentedViewController != nil {
                self.dismiss(animated: true)
            }

            self.descriptionTextView.resignFirstResponder()
        }
    }
}

// MARK: - Actions

extension LocationDetailsViewController {
    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view else {
            return
        }

        let hudView = HudView.hud(inView: mainView, animated: true)
        hudView.text = "Tagged"

        let location: Location

        if let locationToEdit {
            hudView.text = "Updated"
            location = locationToEdit
        } else {
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }

        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark

        if let image {
            // 1
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            // 2
            if let data = image.jpegData(compressionQuality: 0.5) {
                // 3
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }

        do {
            try managedObjectContext.save()

            afterDelay(0.6) { [weak self] in
                hudView.hide()
                self?.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalCoreDataError(error)
        }
    }

    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
}

// MARK: - Helper Methods

extension LocationDetailsViewController {
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let tmp = placemark.subThoroughfare {
            text += tmp + " "
        }
        if let tmp = placemark.thoroughfare {
            text += tmp + ", "
        }
        if let tmp = placemark.locality {
            text += tmp + ", "
        }
        if let tmp = placemark.administrativeArea {
            text += tmp + " "
        }
        if let tmp = placemark.postalCode {
            text += tmp + ", "
        }
        if let tmp = placemark.country {
            text += tmp
        }
        return text
    }

    func format(date: Date) -> String {
        dateFormatter.string(from: date)
    }
}

// MARK: Navigation

extension LocationDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
}

// MARK: - Table View Delegates

extension LocationDetailsViewController {
    override func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        indexPath.section == 0 || indexPath.section == 1 ? indexPath : nil
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
}

// MARK: - Image Helper Methods

extension LocationDetailsViewController {
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }

    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        present(imagePicker, animated: true)
    }

    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        present(imagePicker, animated: true)
    }

    func showPhotoMenu() {
        let allert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )

        let takePhotoAction = UIAlertAction(
            title: "Take Photo",
            style: .default
        ) { [weak self] _ in
            self?.takePhotoWithCamera()
        }

        let chooseFromLibraryAction = UIAlertAction(
            title: "Choose From Library",
            style: .default
        ) { [weak self] _ in
            self?.choosePhotoFromLibrary()
        }

        allert.addAction(cancelAction)
        allert.addAction(takePhotoAction)
        allert.addAction(chooseFromLibraryAction)

        present(allert, animated: true)
    }
}

// MARK: - Image Picker Delegates

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
