--Cleaning Data in SQL series


select * from NashvilleHousing
select SaleDate from NashvilleHousing

alter  table NashvilleHousing
alter column SaleDate date
--Thay vi thay đổi định dạng thì có thể add thêm 1 cột mới
---Alter table NashvilleHousing 
	--Add SaleDateConverted Date;

---Update NashvilleHousing
	--Set SaleDateConverted = Convert(date, SaleDate)


--2.Populate Property Address data

Select *
From NashvilleHousing
Where PropertyAddress is null
order by ParcelID

--Cách 1: sử dụng các thông tin có sẵn để populate 
-- i will use JOIN 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID]
where a.PropertyAddress is null
--Sau đó populate lại data bằng Update và isnull
update a 
set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
	
From NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Colums (Address, City , State

select PropertyAddress
from NashvilleHousing
--Sử dụng substring để chọn ra các phần mà mình muốn
select 
substring (PropertyAddress, 1, Charindex(',', propertyaddress)-1) as Address,
substring (PropertyAddress, Charindex(',', PropertyAddress)+1 , len(PropertyAddress)) as Address
from NashvilleHousing


--tạo ra 2 cột mới, gồm cột address và city

alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = substring (PropertyAddress, 1, Charindex(',', propertyaddress)-1)

alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = substring (PropertyAddress, Charindex(',', PropertyAddress)+1 , len(PropertyAddress))																																																																				

--Cách 2: sử dụng Parsename để phân chia các cột

select 
Parsename(replace(OwnerAddress,',' ,'.'),3 ),
Parsename(replace(OwnerAddress,',' ,'.'),2 ),
Parsename(replace(OwnerAddress,',' ,'.'),1 )
from NashvilleHousing


alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

update  NashvilleHousing
set OwnerSplitAddress = Parsename(replace(OwnerAddress,',' ,'.'),3 )

alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

update  NashvilleHousing
set OwnerSplitCity = Parsename(replace(OwnerAddress,',' ,'.'),2 )

alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255)

update  NashvilleHousing
set OwnerSplitState = Parsename(replace(OwnerAddress,',' ,'.'),1 )

select * from NashvilleHousing

--------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field


select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End
From NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End

select distinct (SoldAsVacant), Count ( SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2


--------------------------------------------------------------------------------------------------------
--Remove Duplicate
---sử dụng row_numer với từng kia cái partition bởi vì chỉ cần những cái này giống nhau --> nó sẽ có 2 row như thế và số thứ tự sẽ là 1, 2 

with RowNumCTE As(
select *,
	ROW_NUMBER() over (Partition by ParcelId,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									Order by  UniqueID) row_num
from NashvilleHousing
)
Select *
from RowNumCTE
where row_num >1
--Sau khi sử dụng select để xác định các thông tin bị trùng lặp thì sử dụng delete để xoa

with RowNumCTE As(
select *,
	ROW_NUMBER() over (Partition by ParcelId,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									Order by  UniqueID) row_num
from NashvilleHousing
)
delete 
from RowNumCTE
where row_num>1
--Cách này nó sẽ không chỏ trực tiếp vào database nên là nó cũng là ưu điểm cũng là nhược điểm

--------------------------------------------------------------------------------------------------------
--Delete Unused Columns 


alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress