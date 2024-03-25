select * from NashvilleHousing


alter table NashvilleHousing
Drop column PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState

 --Step1: Populating the empty Property Address information

 --a: Get to know how to populate blank information
select 
	isnull(a.PropertyAddress, b.PropertyAddress),a.[UniqueID ], a.ParcelID
from NashvilleHousing a 
join NashvilleHousing b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--b: alter blank information with given information

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Step2: Split PropertyAddress into smaller column

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)as [Address],
		substring (PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress)) as [City]
from NashvilleHousing

alter table NashvilleHousing
add Split_address nvarchar(50)

update  NashvilleHousing
set Split_address = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) 

alter table NashvilleHousing
add Split_city nvarchar(50)

update NashvilleHousing
set Split_City = substring (PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress))

--2.b --Way2: Su dung Parsename

select * from NashvilleHousing

select 
	parsename(replace(OwnerAddress,',','.'), 3) as OwnerAddress_Split,
	parsename(replace(OwnerAddress,',','.'), 2) as OwnerCity_Split,
	parsename(replace(OwnerAddress,',','.'), 1) as OwnerState_Split

from NashvilleHousing

alter table NashvilleHousing
add OwnerAddress_Split nvarchar(50)

update NashvilleHousing
set OwnerAddress_Split= parsename(replace(OwnerAddress,',','.'), 3) 


alter table NashvilleHousing
add OwnerCity_Split nvarchar(50)

update NashvilleHousing
set OwnerCity_Split= parsename(replace(OwnerAddress,',','.'), 2) 

alter table NashvilleHousing
add OwnerState_Split nvarchar(50)

update NashvilleHousing
set OwnerState_Split= parsename(replace(OwnerAddress,',','.'), 1) 

select * from NashvilleHousing

--Step 3: remove duplicated information

select
	*,
	ROW_NUMBER() over(partition by  ParcelID, PropertyAddress,SaleDate, SalePrice, OwnerName, OwnerAddress order by UniqueID)
from NashvilleHousing
;
--Nhớ là Partition không nên có UniqueID vì UniqueId thì mỗi cái sẽ có 1 cái khác nhau mà đôi khi thông tin vẫn giống nhau)
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